(function($, undefined_) {
  return $.ui.sortable.prototype._createHelper = function(event) {
    var helper, o;

    o = this.options;
    helper = ($.isFunction(o.helper) ? $(o.helper.apply(this.element[0], [event, this.currentItem])) : (o.helper === "clone" ? this.currentItem.clone() : this.currentItem));
    if (!helper.parents("body").length) {
      $((o.appendTo !== "parent" ? o.appendTo : this.currentItem[0].parentNode))[0].appendChild(helper[0]);
    }
    if (helper[0] === this.currentItem[0]) {
      this._storedCSS = {
        width: this.currentItem[0].style.width,
        height: this.currentItem[0].style.height,
        position: this.currentItem.css("position"),
        top: this.currentItem.css("top"),
        left: this.currentItem.css("left")
      };
    }
    if (helper[0].style.width === "" || o.forceHelperSize) {
      helper.width(this.currentItem.width() - 1);
    }
    if (helper[0].style.height === "" || o.forceHelperSize) {
      helper.height(this.currentItem.height());
    }
    return helper;
  };
})(jQuery);
