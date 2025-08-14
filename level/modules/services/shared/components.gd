class_name Components

static func attach_listener(
    component_instance: Node,
    listener: ComponentListener
):
    if !component_instance.has_signal(listener.signal_name):
        return

    var component_signal: Signal = component_instance.get(listener.signal_name)
    component_signal.connect(listener.callable, listener.flags)

class Component extends RefCounted:
    var scene: PackedScene
    var type: int
    var path: NodePath

    func _init(
        _scene: PackedScene,
        _component_type: int,
        _path: NodePath
    ) -> void:
        self.scene = _scene
        self.type = _component_type
        self.path = _path

class ComponentListener extends RefCounted:
    var signal_name: StringName
    var callable: Callable
    var flags: int

    func _init(
        _signal_name: StringName,
        _callable: Callable,
        _flags: int
    ) -> void:
        self.signal_name = _signal_name
        self.callable = _callable
        self.flags = _flags


class ComponentRegistry extends RefCounted:
    var _lookup: Dictionary[NodePath, Component] = {}
    var _lookup_by_type: Dictionary[int, Array] = {}
    var _listener_lookup_by_component: Dictionary[Component, Array] = {}

    func define_component(
        scene: PackedScene,
        component_type: int,
        path: NodePath
    ) -> Component:
        var comp = Component.new(scene, component_type, path)
        self._lookup[path] = comp
        self._lookup_by_type.get_or_add(component_type, []).push_back(comp)
        return comp

    func define_listener(
        component: Component,
        signal_name: StringName,
        callable: Callable,
        flags: int = 0
    ) -> ComponentListener:
        var listener = ComponentListener.new(signal_name, callable, flags)
        self._listener_lookup_by_component.get_or_add(component, []).push_back(listener)
        return listener

    func define_type_listeners(
        type: int,
        signal_name: StringName,
        callable: Callable,
        flags: int = 0
    ) -> Array[ComponentListener]:
        var listeners: Array[ComponentListener] = []
        var registered = self.list_by_type(type)
        for comp in registered:
            listeners.push_back(
                self.define_listener(
                    comp,
                    signal_name,
                    callable,
                    flags
                )
            )

        return listeners

    func list_by_type(component_type: int):
        return self._lookup_by_type.get(component_type, [])

    func list():
        return self._lookup.values()

    func list_listeners(component: Component):
        return self._listener_lookup_by_component.get(component, [])
