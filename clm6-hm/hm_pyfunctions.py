import os
import numpy as np
import xarray as xr
import cftime
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import glob
import dask
import pickle

import gpflow
import tensorflow as tf
from sklearn.metrics import r2_score


utils_dir = os.path.dirname(__file__)

# ===================== Emulation ==============================

def build_kernel_dict(num_params):
    kernel_noise = gpflow.kernels.White(variance=1e-3)
    kernel_matern32 = gpflow.kernels.Matern32(active_dims=range(num_params), variance=10, lengthscales = np.tile(10,num_params))
    kernel_matern52 = gpflow.kernels.Matern52(active_dims=range(num_params),variance=1,lengthscales=np.tile(1,num_params))
    kernel_bias = gpflow.kernels.Bias(active_dims = range(num_params))
    kernel_linear = gpflow.kernels.Linear(active_dims=range(num_params),variance=[1.]*num_params)
    kernel_poly = gpflow.kernels.Polynomial(active_dims = range(num_params),variance=[1.]*num_params)
    kernel_RBF = gpflow.kernels.RBF(active_dims = range(num_params), lengthscales=np.tile(1,num_params))
    
    kernel_dict = {
        0: kernel_linear + kernel_noise,
        1: kernel_RBF + kernel_linear + kernel_noise,
        2:kernel_matern32 + kernel_noise,
        3:kernel_matern32*kernel_linear + kernel_noise,
        4:kernel_linear*kernel_RBF + kernel_matern32 + kernel_noise
    }
    return kernel_dict

def select_kernel(kernel_dict,X_train,X_test,y_train,y_test):
    stdev = []
    r2 = []
    for k in range(len(kernel_dict)):
        kernel = kernel_dict[k]
        emulator = train_model(X_train, y_train, kernel)
        y_pred, sd, cd = validate_model(emulator, X_test, y_test)
        stdev.append(np.mean(sd))
        r2.append(cd)

    # z-score normalization
    r2_z = (r2 - np.mean(r2)) / (np.std(r2) + 1e-12)
    std_z = (stdev - np.mean(stdev)) / (np.std(stdev) + 1e-12)
    std_z = -std_z # invert std so "smaller is better"

    score = 0.8*r2_z + 0.2*std_z
    best_kernel = kernel_dict[np.argmax(score)]
    
    return best_kernel

def train_model(X_train, y_train, kernel):
    model = gpflow.models.GPR(data=(X_train, np.float64(y_train)), kernel=kernel, mean_function=None)
    opt = gpflow.optimizers.Scipy()
    opt_logs = opt.minimize(model.training_loss, model.trainable_variables, options=dict(maxiter=30))
    return model

def validate_model(model, X_test, y_test):
    y_pred, y_pred_var = model.predict_y(X_test)
    sd = y_pred_var.numpy().flatten()**0.5
    coef_deter = r2_score(y_test, y_pred.numpy())
    return y_pred, sd, coef_deter

def save_model(model, savedir, num_params):
    model.compiled_predict_f = tf.function(
        lambda X: model.predict_f(X, full_cov=False),
        input_signature=[tf.TensorSpec([None, num_params], tf.float64)],
    )
    tf.saved_model.save(model, savedir)

def plot_emulator_val(y_test, y_pred, sd, coef_deter, outfile):
    plt.figure()
    plt.errorbar(y_test, y_pred.numpy().flatten(), yerr=2*sd, fmt="o")
    plt.text(0.02, 0.98, f'R² = {np.round(coef_deter, 2)}',fontsize=10,transform=plt.gca().transAxes,va='top',ha='left')
    plt.text(0.02, 0.93, f'Emulator stdev ≈ {np.round(np.mean(sd), 2)}',fontsize=10,transform=plt.gca().transAxes,va='top',ha='left')
    plt.plot([0,np.max(y_test)],[0,np.max(y_test)],linestyle='--',c='k')
    plt.xlabel('CLM')
    plt.ylabel('Emulated')
    plt.xlim([np.min(y_test),np.max(y_test)])
    plt.ylim([np.min(y_test),np.max(y_test)])
    plt.tight_layout()
    plt.savefig(outfile)


def build_biome_X(ds_params, u_params, pft_params, biome_pfts):
    # get universal parameters
    u = ds_params.sel(param=u_params, pft=1).values
    X_arrays = [u]

    # Add each pft param for this biome
    for pft in biome_pfts:
        p = ds_params.sel(param=pft_params, pft=pft).values
        X_arrays.append(p)

    X = np.concatenate(X_arrays, axis=1)

    return X
    
# ===================================================
# ===========    History Matching   =================

def calc_Implausibility(model_mean,model_var,obs_mean,obs_var):
        # implausibility score
        I = np.abs(obs_mean-model_mean) / np.sqrt(obs_var + model_var)
        return I


def call_biome_emulator(sample_df, biome_id, emulator_object, biome_info_dict):

    # Subset the sample DataFrame by selecting columns by name
    biome_params = biome_info_dict[biome_id]['biome_parameters']
    biome_specific_sample_df = sample_df[biome_params]

    # Call the emulator and predict the sample
    y_pred, y_pred_var = emulator_object.compiled_predict_f(biome_specific_sample_df.values)

    return y_pred, y_pred_var


def sample_and_score(data, N, n, num_params):
    index = np.arange(data.shape[0]) 

    # take N random samples of size n
    draws_ix = np.array([np.random.choice(index, size=n, replace=False) for _ in range(N)])

    # Compute scores for each sampled subset
    nbins = 20 # for LHC
    L = np.zeros(N) 
    for i in range(N):
        s = data[draws_ix[i, :], :]
        L[i] = LHC_score(n, nbins, num_params, s)
    
    # Find the best subset (minimum score)
    min_score_ix = np.argmin(L)
    
    return draws_ix[min_score_ix, :]


def LHC_score(n,nbins,num_params,sample):
    # sample is np array with rows as ensemble members and columns as parameters
    # zero is a perfect Latin Hypercube
    Pb = n/nbins
    dim_count = []
    for di in range(num_params):
        data = sample[:,di]
        bin_count = []
        for bi in range(nbins):
            bin_width = 1/20
            bin_min = bi/nbins
            bin_max = bi/nbins+bin_width
            Ab = np.sum((data>bin_min)&(data<bin_max))
    
            bin_count.append(np.abs(Pb - Ab))
        dim_count.append(np.sum(bin_count))
    
    return np.sum(dim_count)

