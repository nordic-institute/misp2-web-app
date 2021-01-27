/*
Vertigo Tip by www.vertigo-project.com
Requires jQuery
*/

this.vtip = function() {
	this.xOffset = 8; // x distance from mouse
	this.yOffset = -8; // y distance from mouse

	$('.vtip').unbind().hover(
		function(e) {
			this.t = this.title;
			this.title = '';
			this.top = (e.pageY + yOffset); this.left = (e.pageX + xOffset);

			$('body').append( '<span id="vtip">' + this.t + '</span>' );
			$('#vtip').css('top', this.top + 'px').css('left', this.left + 'px').fadeIn(250);
		},
		function() {
			this.title = this.t;
			$('#vtip').fadeOut(250).remove();
		}
	).mousemove(
		function(e) {
			this.top = (e.pageY + yOffset - $('#vtip').outerHeight());
			this.left = (e.pageX + xOffset);

			$('#vtip').css('top', this.top + 'px').css('left', this.left + 'px');
		}
	);
};
jQuery(document).ready(function($){vtip();})