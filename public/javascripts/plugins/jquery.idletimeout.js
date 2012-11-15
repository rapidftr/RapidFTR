(function($){
	
	$.idleTimeout = function(element, resume, options){
		
		// overwrite $.idleTimeout.options with the results of $.extend.  Allows you to write and a callback then call it from 
		// from a jQuery UI button or something
		options = $.idleTimeout.options = $.extend({}, $.idleTimeout.options, options);
		
		var IdleTimeout = {
			init: function(){
				var self = this;
				
				this.warning = $(element);
				this.resume = $(resume);
				this.countdownOpen = false;
				this.failedRequests = options.failedRequests;
				this._startTimer();
				
				// start the idle timer
				$.idleTimer(options.idleAfter * 1000);
				
				// once the user becomes idle
				$(document).bind("idle.idleTimer", function(){
					
					// if the user is idle and a countdown isn't already running
					if( $.data(document, 'idleTimer') === 'idle' && !self.countdownOpen ){
						self._stopTimer();
						self.countdownOpen = true;
						self._idle();
					}
				});
				
				// bind continue link
				this.resume.bind("click", function(e){
					e.preventDefault();
					
					window.clearInterval(self.countdown); // stop the countdown
					self.countdownOpen = false; // stop countdown
					self._startTimer(); // start up the timer again
					options.onResume.call( self.warning ); // call the resume callback
				});
			},
			
			_idle: function(){
				var self = this,
					warning = this.warning[0],
					counter = options.warningLength;
				
				// fire the onIdle function
				options.onIdle.call(warning);
				
				// set inital value in the countdown placeholder
				options.onCountdown.call(warning, counter);
				
				// create a timer that runs every second
				this.countdown = window.setInterval(function(){
					counter -= 1;
					
					if(counter === 0){
						window.clearInterval(self.countdown);
						options.onTimeout.call(warning);
					} else {
						options.onCountdown.call(warning, counter);
					}
					
				}, 1000);
			},
			
			_startTimer: function(){
				this.timer = setTimeout(
					$.proxy(this._keepAlive, this),
					options.pollingInterval * 1000
				);
			},
			
			_stopTimer: function(){
				// reset the failed requests counter
				this.failedRequests = options.failedRequests;
				clearTimeout(this.timer);
			},
			
			_keepAlive: function(){
				var self = this;
				
				// if too many requests failed, abort
				if( !this.failedRequests ){
					this._stopTimer();
					options.onAbort.call( this.warning[0] );
					return;
				}
				
				$.ajax({
					timeout: options.AJAXTimeout,
					url: options.keepAliveURL,
					error: function(){
						self.failedRequests--;
						self._startTimer();
					},
					success: function(response){
						if($.trim(response) !== options.serverResponseEquals){
							self.failedRequests--;
						}
						
						self._startTimer();
					}
				});
			}
		};
		
		// run this thang
		IdleTimeout.init();
	};
	
	$.idleTimeout.options = {
		// number of seconds after user is idle to show the warning
		warningLength: 30,
		
		// url to call to keep the session alive while the user is active
		keepAliveURL: "",
		
		// the response from keepAliveURL must equal this text:
		serverResponseEquals: "OK",
		
		// user is considered idle after this many seconds.  10 minutes default
		idleAfter: 600,
		
		// a polling request will be sent to the server every X seconds
		pollingInterval: 60,
		
		// number of failed polling requests until we abort this script
		failedRequests: 5,
		
		// the $.ajax timeout in MILLISECONDS! 
		AJAXTimeout: 250,
		
		/*
			Callbacks
			"this" refers to the element found by the first selector passed to $.idleTimeout.
		*/
		// callback to fire when the session times out
		onTimeout: function(){},
		
		// fires when the user becomes idle
		onIdle: function(){},
		
		// fires during each second of warningLength
		onCountdown: function(){},
		
		// fires when the user resumes the session
		onResume: function(){},
		
		// callback to fire when the script is aborted due to too many failed requests
		onAbort: function(){}
	};
	
})(jQuery);
