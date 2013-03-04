define [
  "jquery",
  "backbone",
  "underscore",
  "select2"  
],($,Backbone,_)-> 
	APIView = Backbone.View.extend
		init_select2:->
			$el = $("input,select", @$el)
			more = parseInt $el.data("js-more") ? 20
			options =
				placeholder: $el.data("js-placeholder")
				ajax:
					url: $el.data("js-url")
					data:(term, page)->
						q: $el.data("js-q")
						page_limit: 10
						page: page
					results:(data,page)->
						{ results:data.results, more:data.more }
			$el.select2(options)
		
		render:->
			type = @model.get("type")
			method = @["init_#{type}"]
			if _.isFunction(method)
				method.apply this, arguments

	APIView