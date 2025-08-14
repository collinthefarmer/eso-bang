
`EntityService` 
- Responsible for creating entities (if none are available in the pool), adding entities to the level, and returning them to their pools when they leave the scene tree.

Entities execute startup/teardown logic via the `_enter_tree` and `_exit_tree` methods.