Remove-Item -Path "./shaders.zip"
Compress-Archive -Path ./shaders -DestinationPath "./shaders.zip" 
Copy-Item -Path "./shaders.zip" -Destination "B:/Libraries/Documents/MultiMC/instances/1.14.4/.minecraft/shaderpacks" -Force