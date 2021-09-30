require 'set'

class Console
  def initialize(player, narrator)
    @player   = player
    @narrator = narrator
  end

  def show_room_description
    @narrator.say "-----------------------------------------"
    @narrator.say "You are in room #{@player.room.number}."

    @player.explore_room

    @narrator.say "Exits go to: #{@player.room.exits.join(', ')}"
  end

  def ask_player_to_act
    actions = {"m" => :move, "s" => :shoot, "i" => :inspect }

    accepting_player_input do |command, room_number|
      @player.act(actions[command], @player.room.neighbor(room_number))
    end
  end

  private

  def accepting_player_input
    @narrator.say "-----------------------------------------"
    command = @narrator.ask("What do you want to do? (m)ove or (s)hoot?")

    unless ["m","s"].include?(command)
      @narrator.say "INVALID ACTION! TRY AGAIN!"
      return
    end

    dest = @narrator.ask("Where?").to_i

    unless @player.room.exits.include?(dest)
      @narrator.say "THERE IS NO PATH TO THAT ROOM! TRY AGAIN!"
      return
    end

    yield(command, dest)
  end
end

class Narrator
  def say(message)
    $stdout.puts message
  end

  def ask(question)
    print "#{question} "
    $stdin.gets.chomp
  end

  def tell_story
    yield until finished?

    say "-----------------------------------------"
    describe_ending
  end

  def finish_story(message)
    @ending_message = message
  end

  def finished?
    !!@ending_message
  end

  def describe_ending
    say @ending_message
  end
end

class Room
  def initialize(number)
    @number = number
    @hazards = []
    @neighbors = []
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
    if empty?
      if neighbors.all? { |neighbor| neighbor.empty?}
        return true
      else
        return false
      end
    else
      return false
    end
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

  def self.dodecahedron

    def initialize(dodecahedron)
      @rooms = (1..20).map.with_object({}) { |index, number| number[index] = Room.new(index)}
      dodecahedron.each {|r1,r2| @rooms[r1].connect(@rooms[r2])}
    end

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
    i = 0
    while i != count
      room = random_room
      redo if room.has?(object)
      room.add(object)
      i += 1
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
  attr_reader :room

  def initialize
    @actions = {}
    @senses = {}
    @encounters = {}
  end

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
