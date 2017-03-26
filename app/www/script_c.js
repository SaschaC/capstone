/* Summary of script:
1. Look up all available languages with proverbs on Wikiquote, parse the Wikitext from all those pages and extract the quotes into objects containing 'language','pageID','meaning','quote','english' (either the translation or english equivalent) ,and 'transliteration' as keys.
2. From the extracted quotes, on click randomly select and display one quote and its information in the html 'quote', 'transliteration', 'language', and 'english' html elements. Update the 'tweet' and 'gtranslate' buttons with info from the randomly selected quote. */

$(document).ready(function() {
  

					$("#predictionButtons").on('click',".btn", function(){
			console.log('foo');
		var colors = update_colors();						
		$("body").css("background-color",colors[0]);	
	});			

});

var update_buttons = function(){
		
	
}

var update_colors = function(){
	var hue = Math.floor(Math.random() * 345);
	var saturation = Math.floor(Math.random() * 40)+60;
	var lightness = 80;
	var backgroundColor = "hsl("+hue+","+saturation+"%,"+lightness+"%)"; 
	lightness += 10;
	var boxColor = "hsl("+hue+","+saturation+"%,"+lightness+"%)"; 
	return [backgroundColor,boxColor];
}