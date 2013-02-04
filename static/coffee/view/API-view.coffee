define [
  "jquery",
  "backbone",
  "underscore",
  "select2"  
],($,Backbone,_)-> 
	APIView = Backbone.View.extend
		updateUI:->
			$el = @$el.find("[data-js-select2]")
			if $el.length > 0
				$el.select2()

	APIView
