class GiftExamples

  attr_accessor :examples

  def initialize
    @examples = [EXAMPLE_1, EXAMPLE_2, EXAMPLE_3]
  end

  EXAMPLE_1 = {
    image: 'gift-example__bag.jpg',
    title: 'JOYN Bags',
    tagline: 'Made by a social enterprise in India, these JOYN bags are 100% handmade.',
    details: [
      "JOYN bags aren't mass-produced. People make them.",
      "Real people with names and faces and stories and passions.",
      'Each bag is unique. No factories, no automation, because the more hands that it takes to make the products, the more jobs we are able to create. We have invented a system of "purposeful inefficiency" that drives every decision of our company.'
    ],
    labels: [
      {icon: 'icon-wrapt-heart', text: 'handmade'},
      {icon: 'icon-wrapt-heart', text: 'fair trade'},
      {icon: 'icon-wrapt-heart', text: 'sustainable'}
    ]
  }

  EXAMPLE_2 = {
    image: 'gift-example__glass.jpg',
    title: 'Glasses',
    tagline: 'Supporting ancient glass blowing (since the eighth century) as an art form in Murano Italy (Venice).',
    details: [
      "Real people with names and faces and stories and passions.",
      'Each bag is unique. No factories, no automation, because the more hands that it takes to make the products, the more jobs we are able to create. We have invented a system of "purposeful inefficiency" that drives every decision of our company.'
    ],
    labels: [
      {icon: 'icon-wrapt-heart', text: 'handmade'},
      {icon: 'icon-wrapt-heart', text: 'fair trade'},
    ]
  
  }

  EXAMPLE_3 = {
    image: 'gift-example__earrings.jpg',
    title: 'Jeweler',
    tagline: 'Hand made by artisan jeweler, combining precious stones with metals to make meaning and beauty.',
    details: [
      "JOYN bags aren't mass-produced. People make them.",
      "Real people with names and faces and stories and passions."
    ],
    labels: [
      {icon: 'icon-wrapt-heart', text: 'handmade'},
      {icon: 'icon-wrapt-heart', text: 'fair trade'},
      {icon: 'icon-wrapt-heart', text: 'Made in India'}
    ]
  }

end