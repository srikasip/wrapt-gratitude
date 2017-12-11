App.PasswordRevealer = class PasswordRevealer {

  constructor() {
    this.addShowHideButtons();
    this.attachShowHideClickHandlers();
  }

  addShowHideButtons() {
    $( "input[type='password']" ).each(function() {
      $(this).wrap( "<div class='input-wrapper'></div>" );
      $(this).addClass('js-pw-input-for-show-hide');
      $(this).after( "<div class='input-wrapper--show-hide js-toggle-show-hide'><i class='fa fa-eye'></i><span>Show</span></div>" );
    });
  }

  attachShowHideClickHandlers() {
    $(document).on('click', '.js-toggle-show-hide', function() {
      let button = $(this)
      let wrapper = button.closest('.input-wrapper')
      let input = wrapper.find('input')
      console.log('clicked!', this, wrapper, input, input.attr('type'))
      if (input.attr('type') === 'password') {
        input.attr('type', 'text');
        button.children('i').addClass('fa-eye-slash');
        button.children('i').removeClass('fa-eye');
        button.children('span').text( "Hide" );
      } else {
        input.attr('type', 'password');
        button.children('i').addClass('fa-eye');
        button.children('i').removeClass('fa-eye-slash');
        button.children('span').text( "Show" );
      }
    });
  }
}