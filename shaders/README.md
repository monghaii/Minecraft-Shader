### Custom Minecraft Shader program.

There are 3 general sets of background knowledge for shader development: GLSL, optifine's rendering pipeline, and linear algebra.

GLSL is OpenGL's Shader Language. There are quite a few tutorials for this on the internet, but minecraft in partucular uses an old openGL version, so it might be useful to try to find an equally old GLSL tutorial. Anything that says OpenGL 2.1 or #version 120 will work. One such tutorial that someone here recommended is https://www.lighthouse3d.com/tutorials/glsl-12-tutorial/

Optifine's rendering pipeline has a bit of documentation in the docs folder: https://github.com/sp614x/optifine/tree/master/OptiFineDoc/doc. in particular, look at shaders.txt and shaders.properties. Additionally, I've also written my own "tutorial" for it here https://pastebin.com/aB5MJ7aN which explains the basic order in which things happen and what the various files do.

Once you have all that down, there are 2 basic paths you can go with: edit someone else's pack, or make your own. I would personally recommend editing someone else's pack to start off with until you get a decent idea of how it works. Then, try making your own pack from scratch. I'd recommend using this pack as a base for "from scratch" shaders: https://www.dropbox.com/s/vkl1vkdwwh0xrab/base.zip?dl=0. It has all the basic files included, but none of them actually do anything. This makes it very easy to edit.

### Troubleshooting

# I got a pack to work, but I'm getting really bad framerate while it's enabled.

Pretty graphics don't come out of nowhere. All shader packs will be worse on framerate than not having any shader packs enabled at all. Sometimes, this is unavoidable, because there's no fast way of doing a certain effect. The good news however is that some packs have config options to disable certain effects. The config options for shader packs can be accessed by clicking "shader options" in the bottom right corner of the shader selection menu. Mess around with this menu a bit, and try disabling or reducing effects that you don't care about.

# My game is just flat out crashing when I enable shaders!

First, open up your crash log and take a look at it. Crash logs can be found in .minecraft/crash-reports. If your crash log starts with "java.lang.NoSuchFieldError: field_191308_b", then this is an easy fix. Either update to the latest PREVIEW version of optifine, OR delete "entity.properties" inside your shader pack. If your crash log does NOT start with that specific error, then ask about it in #main_support. Be sure to upload the crash log itself too, as we can't really help much without that.