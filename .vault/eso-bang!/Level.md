
## Heat



## Terrain

- Level terrain is based on a X\*Y plane, with heights for each integer coordinate on the plane determined by sampling a heightmap.
- Terrain is made up of a collision shape and a mesh.
- Heights can be modified by specific invocations.
	- Height modification should happen gradually to prevent any collision issues with tokens.
		- *or*, height modification should take into account any affected bodies and manually displace them as the terrain is being manipulated.


