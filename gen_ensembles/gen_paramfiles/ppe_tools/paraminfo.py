class ParamInfo(object):
    """
    Stores parameter information.
    """
    
    def __init__(self, name, loc, precision=None, defval=None, value=None, lhc=None, flag=None):
        self._name = name # parameter name
        self._default = defval # default value
        self._value = value # actual value to be used in a given ensemble member
        self._location = loc # location of parameter (params file or namelist)
        self._precision = precision
        self._lhc = lhc
        self._flag = flag

    @property
    def name(self):
        return self._name

    @property
    def default(self):
        return self._default
    
    @property
    def value(self):
        return self._value
    
    @property
    def location(self):
        return self._location

    @property
    def precision(self):
        return self._precision
    
    @property
    def lhc(self):
        return self._lhc
    
    @property
    def flag(self):
        return self._flag
    
    @name.setter
    def name(self, new_name):
        self._name = new_name
        
    @default.setter
    def default(self, new_def):
        self._default = new_def
        
    @value.setter
    def value(self, new_val):
        self._value = new_val
            
    def __repr__(self):
                # Format the value using the precision string, if available
        if self.precision:
            try:
                val_str = format(self.value, self.precision)
            except (ValueError, TypeError):
                val_str = str(self.value)
        else:
            val_str = self.value
            
        return "%s:\n\tloc = %s\n\tprecision = %s\n\tdefault = %s\n\tvalue = %s\n\tlhc_sample = %s\n\tflag = %s" % (self.name, self.location, self.precision, self.default, self.value, self.lhc, self.flag)
