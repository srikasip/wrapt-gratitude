App.PasswordRevealer = class PasswordRevealer {

  constructor() {
    this.addShowHideButton();
    this.handleShowHideClick();
  }

  addShowHideButton() {
    $( "input[type='password']" ).wrap( "<div class='input-wrapper'></div>" );
    $( "input[type='password']" ).attr( 'id', 'js-pw-input-for-show-hide');
    $( "input[type='password']" ).after( "<div class='input-wrapper--show-hide' id='js-toggle-show-hide'><i class='fa fa-eye'></i><span>Show</span></div>" );
  }

  handleShowHideClick() {
    $('#js-toggle-show-hide').click(function() {
      if ($('#js-pw-input-for-show-hide').attr('type') === 'password') {
        $('#js-pw-input-for-show-hide').attr('type', 'text');
        $(this).children('i').addClass('fa-eye-slash');
        $(this).children('i').removeClass('fa-eye');
        $(this).children('span').text( "Hide" );
      } else {
        $('#js-pw-input-for-show-hide').attr('type', 'password');
        $(this).children('i').addClass('fa-eye');
        $(this).children('i').removeClass('fa-eye-slash');
        $(this).children('span').text( "Show" );
      }
    });
  }

}