module ApplicationHelper

  NAMES = %w(Aardvark Albatross Alligator Alpaca Ant Anteater Antelope Ape Armadillo Baboon Badger Barracuda Bat Bear Beaver Bee Bison Boar Butterfly Camel Capybara Caribou Cassowary Cat Caterpillar Chamois Cheetah Chicken Chimpanzee Chinchilla Chough Clam Cobra Cockroach Cod Cormorant Coyote Crab Crane Crocodile Crow Curlew Deer Dinosaur Dog Dogfish Dolphin Donkey Dotterel Dove Dragonfly Duck Dugong Dunlin Eagle Echidna Eel Eland Elephant Elk Emu Falcon Ferret Finch Fish Flamingo Fly Fox Frog Gaur Gazelle Gerbil Giraffe Gnat Gnu Goat Goose Goldfinch Goldfish Gorilla Goshawk Grasshopper Grouse Guanaco Gull Hamster Hare Hawk Hedgehog Heron Herring Hippopotamus Hornet Horse Human Hummingbird Hyena Ibex Ibis Jackal Jaguar Jay Jellyfish Kangaroo Kingfisher Koala Kookabura Kouprey Kudu Lapwing Lark Lemur Leopard Lion Llama Lobster Locust Loris Louse Lyrebird Magpie Mallard Manatee Mandrill Mantis Marten Meerkat Mink Mole Mongoose Monkey Moose Mouse Mosquito Mule Narwhal Newt Nightingale Octopus Okapi Opossum Oryx Ostrich Otter Owl Oyster Panther Parrot Partridge Peafowl Pelican Penguin Pheasant Pig Pigeon Pony Porcupine Porpoise Quail Quelea Quetzal Rabbit Raccoon Rail Ram Rat Raven Reindeer Rhinoceros Rook Salamander Salmon Sandpiper Sardine Scorpion Seahorse Seal Shark Sheep Shrew Skunk Snail Snake Sparrow Spider Spoonbill Squid Squirrel Starling Stingray Stinkbug Stork Swallow Swan Tapir Tarsier Termite Tiger Toad Trout Turkey Turtle Vicuña Viper Vulture Wallaby Walrus Wasp Weasel Whale Wolf Wolverine Wombat Woodcock Woodpecker Worm Wren Yak )

  COLORS = %w(#CFF09E #A8DBA8 #79BD9A #3B8686 #0B486B)

  def percentages number_of_sets = 7, spread = 50
    percentages = []
    number_of_sets.times.to_a.each { |i| percentages << rand(50) + 1 }
    percentages
  end

  def color index
    COLORS[index]
  end

  def colors
    5.times.map.each do |i|
      color(i)
    end.join(',')
  end

  def random_name
    NAMES.sample
  end

end
