$ ->
	$('.dashboard-button').hover(
		-> $(this).css 'background-image', $(this).css('background-image').replace('gray', 'blue')
		-> $(this).css 'background-image', $(this).css('background-image').replace('blue', 'gray')
	)