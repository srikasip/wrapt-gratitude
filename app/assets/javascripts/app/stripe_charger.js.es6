// https://stripe.com/docs/stripe.js?
// https://stripe.com/docs/elements/reference

App.StripeCharger = class StripeCharger {
  constructor(stripePublishableKey) {
    var elements

    this.nameSelector = '#cardholder-name';
    this.cardNumberSelector = '#js-card-number';
    this.expirySelector = '#js-expiry';
    this.cvcSelector ='#js-cvc';
    this.postalCodeSelector = '#js-postal-code';
    this.config = { style: { base: { '::placeholder': {color: '#FFF' } } } };

    this.stripe = Stripe(stripePublishableKey);
    elements = this.stripe.elements();
    this.cardNumber = elements.create('cardNumber', this.config);
    this.cardExpiry = elements.create('cardExpiry', this.config);
    this.cardCvc = elements.create('cardCvc', this.config);
    this.cardPostalCode = elements.create('postalCode', this.config);
    this.formReady = false;
  }

  activate() {
    // Add an instance of the card Element into the `card-element` <div>
    this.cardNumber.mount(this.cardNumberSelector);
    this.cardExpiry.mount(this.expirySelector);
    this.cardCvc.mount(this.cvcSelector);

    this.form = $(this.cardNumberSelector).closest('form');
    this.errorContainer = this.form.find(this.paymentErrorsSelector);

    this.cardNumber.addEventListener('change', this.setOutcome);
    this.cardExpiry.addEventListener('change', this.setOutcome);
    this.cardCvc.addEventListener('change', this.setOutcome);

    // Create a token or display an error the form is submitted.
    this.form.on('submit', (event) => { this.submitHandler(event) });
  }

  submitHandler(event) {
    if (this.formReady) {
      return;
    }

    event.preventDefault();

    this.stripe.createToken(this.cardNumber, {name: $(this.nameSelector).val, address_zip: $(this.postalCodeSelector).val}).then( (result) => {
      if (result.error) {
        this.errorContainer.html(result.error.message);
        this.errorContainer.removeClass('invisible');

        setTimeout(
          () => {
            $(this.form.find('input[type=submit]')).prop('disabled', false)
            console.debug(this.form.find('input[type=submit]'))
          },
          400
        );
      } else {
        // Send the token to your server
        this.stripeTokenHandler(result.token, this);
      }
    })
  }

  stripeTokenHandler(token, that) {
    // Insert the token ID into the form so it gets submitted to the server
    var hiddenInput = $('<input>');
    hiddenInput.attr('type', 'hidden');
    hiddenInput.attr('name', 'stripeToken');
    hiddenInput.attr('value', token.id);

    that.form.append(hiddenInput);
    that.formReady = true;
    that.form.submit();
  }

  setOutcome(result) {
    var paymentErrorsSelector = '#js-stripe-errors';
    var errorElement = document.querySelector(paymentErrorsSelector);

    if (result.error) {
      errorElement.textContent = result.error.message;
      errorElement.classList.remove('invisible');
    } else {
      errorElement.textContent = "";
      errorElement.classList.add('invisible');
    }
  }
}
