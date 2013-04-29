var DATA_MODEL, DATA_TYPE, DATA_VIEW, LOG, isPositiveInt, toInt;

DATA_VIEW = "$view";

DATA_TYPE = "component-type";

DATA_MODEL = "$model";

LOG = function(type, msg) {
  return console.error("" + type + " " + msg);
};

toInt = function(v) {
  if (v === "") {
    return 0;
  } else {
    return parseInt(v);
  }
};

isPositiveInt = function(v) {
  return /^\d+$/.test(v);
};
