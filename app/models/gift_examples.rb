class GiftExamples

  # attr_accessor :examples

  def initialize
    # @examples = [EXAMPLE_1, EXAMPLE_2, EXAMPLE_3]
  end

  def home_page_stories
    [EXAMPLE_7, EXAMPLE_1, EXAMPLE_5]
  end

  def rewrapt_stories
    [EXAMPLE_1, EXAMPLE_2, EXAMPLE_3, EXAMPLE_4, EXAMPLE_5, EXAMPLE_6, EXAMPLE_7]
  end


  EXAMPLE_1 = {
    image: 'gift-example__lesouk.jpg',
    title: 'Le Souk Ceramique',
    tagline: 'Handmade dishes and olive wood products, keeping alive an ancient Mediterranean tradition alive.',
    details: [
      'Established by an American after living in Tunisia for decades, today Le Souk is a joint venture that supports 60 extended families that are able to live on fair wages, send their children to school and continue their craft.'
    ],
    labels: [
      {icon: 'icon-source-handmade', text: 'handmade'},
      {icon: 'icon-source-ancient-tradition', text: 'ancient tradition'},
      {icon: 'icon-source-integrity', text: 'made with integrity'}
    ]
  
  }

  EXAMPLE_2 = {
    image: 'gift-example__ford.jpg',
    title: 'Kristin Ford Jewelry',
    tagline: 'Kristin Ford believes in the energetic and healing power of gemstones.',
    details: [
      "For nearly 25 years, Kristin for has been creating a line of jewelry based on her respect for the gifts of the gemstones she works with.",
      "Her pieces can be found in galleries and boutiques across the US and overseas, but it is all made exclusively in her studio in the US.",
      "A portion of all sales is donated locally, nationally and internationally."
    ],
    labels: [
      {icon: 'icon-source-usa', text: 'made in US'},
      {icon: 'icon-source-integrity', text: 'made with integrity'},
      {icon: 'icon-source-sustainable', text: 'sustainable'}
    ]
  }

  EXAMPLE_3 = {
    image: 'gift-example__dutch-bow.jpg',
    title: 'DutchBow',
    tagline: 'The designer gets much of her design inspiration from her global travels, making her pieces in the US.',
    details: [
      "Ariane Harris started Dutch Bow out of the need to be creative while staying at home raising my two sons, Dutch and Bowie. Today, they share a play/work space filled with creative pursuits.",
      "Having lived and traveled all over Europe and spent time in Morocco, Turkey and Mexico, the designer spots global fashion trends and incorporates them into her pieces."
    ],
    labels: [
      {icon: 'icon-source-usa', text: 'made in US'},
      {icon: 'icon-source-handmade', text: 'handmade'},
      {icon: 'icon-source-integrity', text: 'made with integrity'},
    ]
  }

  EXAMPLE_4 = {
    image: 'gift-example__chickahisa.jpg',
    title: 'Chikihisa Studio',
    tagline: 'showcasing the \'beauty of imperfection\'',
    details: [
      "Ann Chikahisa never planned on becoming a jewelry designer until she took a metal-smithing class that inspired her and gave her the confidence to start a whole new direction in life..",
      "Based in Seattle, Ann’s mission today is to bring more style and the beauty of to life by showcasing organic shapes, textures and what she calls, \'the beauty of imperfection\'."
    ],
    labels: [
      {icon: 'icon-source-handmade', text: 'handmade'},
      {icon: 'icon-source-integrity', text: 'made with integrity'},
      {icon: 'icon-source-usa', text: 'made in US'}
    ]
  }

  EXAMPLE_5 = {
    image: 'gift-example__elements-truffles.jpg',
    title: 'Elements Truffles',
    tagline: 'Handcrafted, organic, made in the US, and supporting children and education.',
    details: [
      "Elements Truffles are artisanal chocolates designed with Ayurveda super foods  to be kind to your body, mind, taste buds and the environment.",
      "Elements  also commits 25% of its profits to Care for Children, an organization that supports the education of under-privileged children in tribal areas of India. For more details visit www.careforchildren.org."
    ],
    labels: [
      {icon: 'icon-source-organic', text: 'organic'},
      {icon: 'icon-source-women-girls', text: 'supporting women & girls'},
      {icon: 'icon-source-sustainable', text: 'sustainable'}
    ]
  }

  EXAMPLE_6 = {
    image: 'gift-example__aria-lucia.jpg',
    title: 'Aria, by Lucia',
    tagline: 'Handcrafted in the Pacific Northwest and made with the finest natural botanicals and essential oils',
    details: [
      "The Founder and maker of Aria by Lucia, gets her inspiration from operatic singing and music. Her passion is to combine fragrance notes that tell a story, the way an aria tells a story through song.  Harmonizing these scents to radiate beauty and grace is a powerful motivation for her as a maker.",
      "Aria is handcrafted on Whidbey Island in in the Pacific Northwest. The products are rich in the finest natural botanicals and skin care ingredients, along with aromas and scents from pure essential oils."
    ],
    labels: [
      {icon: 'icon-source-handmade', text: 'handmade'},
      {icon: 'icon-source-usa', text: 'made in US'},
      {icon: 'icon-source-integrity', text: 'made with integrity'}
    ]
  }

  EXAMPLE_7 = {
    image: 'gift-example__indigo.jpg',
    title: 'Indigo Handloom',
    tagline: 'Indigo Handloom scarves are made from 100% certified organic, non- GMO cotton.',
    details: [
      "Each scarf is completely hand woven (without electricity!) through the traditional textile art of khadi, which is practiced in rural india.  Using natural and low-impact dyes, organic fibers are then woven on looms, supporting hundreds of weavers and their families.",
      "Indigo Handloom has worked with more than 500 weavers to preserve this ancient art form, enabling weavers to provide for their families with fair wages, good working conditions and zero tolerance for child labor. "
    ],
    labels: [
      {icon: 'icon-source-organic', text: 'organic'},
      {icon: 'icon-source-women-girls', text: 'supporting women & girls'},
      {icon: 'icon-source-ancient-tradition', text: 'ancient art form'}
    ]
  }

end