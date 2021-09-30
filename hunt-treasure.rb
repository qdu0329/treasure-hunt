class Room
  def initialize(number)
    @number = number
    @neighbors = []
    @hazards = []
  end

  attr_reader :number, :neighbors, :hazards

#check hazards and safety
  def has?(object)
    if @hazards.include?(object)
      return true
    else
      return false
    end
  end
  def empty?
    if @hazards.empty?
      return true
    else
      return false
    end
  end
  def safe?
    empty? && neighbors.all? { |neighbor| neighbor.empty?}
  end

  def add(object)
    @hazards << object
  end
  def remove(object)
    @hazards.delete(object)
  end

  def neighbor(number)
    neighbors.find { |neighbor| neighbor.number == number}
  end

  def random_neighbor
    neighbors.sample
  end

  def exits
    neighbors.map { |n| n.number}
  end

  def connect(other_room)
    neighbors << other_room
    other_room.neighbors << self
  end
end






class Cave
  def initialize(array)
    @rooms = (1..20).map.with_object({}) { |i, j| j[i] = Room.new(i)}
    array.each {|a,b| @rooms[a].connect(@rooms[b])}
  end

  def self.dodecahedron
    cave = Cave.new([[1,2], [1,5], [1,8], [2,3], [2,10],
        [3,12], [3,4], [4,14], [4,5], [5,6],
        [6,15], [6,7], [7,8], [7,17], [8,11],
        [9,10], [9,12], [9,19], [10,11], [11,20],
        [12,13], [13,14], [13,18], [14,15], [15,16],
        [16,17], [16,18],[17,20], [18,19], [19,20]]
        )
    return cave
  end

  def room(number)
    @rooms[number]
  end

  def random_room
    @rooms.values.sample
  end

  def add_hazard(object, count)
    count.times do
      room = random_room
      redo if room.has?(object)
      room.add(object)
    end
  end

  def room_with(object)
    @rooms.values.find { |o| o.has?(object)}
  end

  def move(object, oldRoom, newRoom)
    oldRoom.remove(object)
    newRoom.add(object)
  end

  def entrance
    @entrance = @rooms.values.find(&:safe?)
  end
end





class Player
  def initialize
    @senses = {}
    @encounters = {}
    @actions = {}
  end

  attr_reader :room

  def sense(object, &callback)
    @senses[object] = callback
  end

  def encounter(object, &callback)
    @encounters[object] = callback
  end

  def action(object, &callback)
    @actions[object] = callback
  end

  def enter(room)
    @room = room
    @encounters.each do |object, action|
      return(action.call) if room.has?(object)
    end
  end

  def explore_room
    @senses.each do |object, action|
      action.call if @room.neighbors.any? {|room| room.has?(object)}
    end
  end

  def act(action, room)
    @actions[action].call(room)
  end
end
