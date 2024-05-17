extends Node
class_name State

@export var player : CharacterBody3D

signal Transitioned

func Enter():
	pass

func Exit():
	pass

func Process(_delta:float):
	pass

func Physics_Process(_delta: float):
	pass
