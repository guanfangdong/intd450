extends StaticBody2D

var RAYCASTING = false
var target

func _ready():
	pass

func _physics_process(delta):
	pass

func takeDamage():
	var enemies = get_tree().get_nodes_in_group("Monster")
	for enemy in enemies:
		enemy.findNewTarget();
	var mirrorsLeft = get_tree().get_nodes_in_group("Mirror")
	if len(mirrorsLeft)-1 == 0:
		var blockers = get_tree().get_nodes_in_group("StairBlocker")
		for blocker in blockers:
			blocker.queue_free();
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Monster"):
		target = body
		var space_state = get_world_2d().direct_space_state
		
		var target_extents = target.get_node('CollisionShape2D').shape.extents - Vector2(5, 5)
		var nw = target.position - target_extents
		var se = target.position + target_extents
		var ne = target.position + Vector2(target_extents.x, -target_extents.y)
		var sw = target.position + Vector2(-target_extents.x, target_extents.y)
		for pos in [nw, ne, se, sw]:
			var result = space_state.intersect_ray(position, target.position, 
											[self], collision_mask)
			if result:
				if result.collider.name == "Monster":
					$Sprite.flip_v = true
					result.collider.target = self

func _on_Area2D_body_exited(body):
	RAYCASTING = false