extends RigidBody2D

#var gravity = 6.6743 * pow(10,-11) # realistic gravity
var gravity = 5000
#export var mass = 0.0
var velocity = Vector2.ZERO
var group = "gravity_2d_bodies"

func _ready():
	self.add_to_group(group)
	
func _process(delta):
	self.apply_impulse(Vector2.ZERO, gravity_from_all_bodies() * delta)
	
func find_all_bodies(node: Node):
	var bodies = []
	if node == null:
		node = get_tree().current_scene
	
	for sub_node in node.get_children():
		if sub_node.is_in_group(group):
			bodies.append(sub_node)
		else:
			bodies.append_array(find_all_bodies(sub_node))
			
	return bodies
	

func gravity_from_all_bodies():
	var acceleration = Vector2.ZERO
	var bodies = find_all_bodies(null)
	for body in bodies:
		if body != self:
			# Check if the collision layer/masks collide.
			if self.collision_layer & body.collision_mask:
				var acc = gravity_for_single_body(body)/mass
				acceleration += acc
	
	# Seems to fix issue with larger objects not accelarating as fast as they should.
	# Necessary because the force of gravity is calculated as if the object that's being acted on has a mass of 1.
	var mass_squared = mass * mass
	return acceleration * mass_squared

func gravity_for_single_body(body: CollisionObject2D):
	#var distance = position.distance_to(body.position)
	var distance = position.distance_squared_to(body.position)
	var force = gravity * body.mass / distance
	var vector = (body.position - position).normalized()
	var force_vector = force * vector
	return force_vector

#func _integrate_forces(state):
#	self.apply_impulse(Vector2.ZERO, gravity_from_all_bodies())
