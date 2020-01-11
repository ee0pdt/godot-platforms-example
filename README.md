# Platforms
Example of how to do moving platforms in GDScript

The platform scene has a number of exported variables which can be used to setup the platform. Very much a work in progress. PRs welcomed.

## How to use platform:

1. Add the platform scene to your main scene
2. Right click the scene in the outline and choose "Editable Children"
3. Move the start position and end position to where you want the platform to go
4. Set the mode and total time for the platform

## Settings:

### Mode:
Auto: Platform moves to and from the start and end positions automatically without stopping
Manual: Platform will stop when reaching the target node

### Target:
Is platfrom heading towards the start or towards the end point, more useful when scripting

### Is Active:
Whether the platform is initially active

## TODO:

1. Add signals to enable platform start/stop
2. Add tweening options
3. Non-linear paths???
