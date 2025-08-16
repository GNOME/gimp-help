# generate to per language images, but if language has replacements then
# those replacement translated images need to be used instead of the
# versions here!

images_base_examples = [
    'apple-banana.png',
    'sunflower.png',
]

img_base_path = meson.project_source_root() + '/images/C/base-examples/'
images_list = images_base_examples
path_images = []

foreach img: images_list
    path_image   = img_base_path + img
    path_images += path_image
    message('Path image: ' + path_image)
endforeach

images_base_examples_path = path_images
