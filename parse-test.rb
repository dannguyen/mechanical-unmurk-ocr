## Just a proof of concept: 
#   open a tiff
#   tesseract it into hOCR
#   parse hOCR
#   split tiff into OCR'ed entities
#   ??
#   get coffee

require 'rubygems'
require 'rmagick'
require 'nokogiri'
require 'fileutils'

ROOT_PATH = File.dirname(__FILE__)
TEST_FILE = File.join(ROOT_PATH, 'process-files', 'um-tess-test.tif')
_FP = {
  'tesseract_config' => File.join(ROOT_PATH, 'tesseract.cfg')
}


fname_original = TEST_FILE
fname_dir = File.dirname(fname_original)
fname_basename = File.basename(fname_original).split('.')[0..-2].join('.')

fname_output_dir = File.join(fname_dir,'__output_files', fname_basename)
FileUtils.makedirs(fname_output_dir)

fname_base = File.join(fname_dir, fname_basename)
fname_base_output = "#{fname_base}-hocr"

# produce tesseract output
tess_cmd = "tesseract #{fname_original} #{fname_base_output} -l eng +#{_FP['tesseract_config']}"
`#{tess_cmd}`

hocr_fname = fname_base_output + ".html"
raise "hOCR output failed" unless File.exists?hocr_fname


# rmagick
## get dimensions of file
## 
puts "RMagick:: Opening #{fname_original}"
r_img = Magick::Image::read(fname_original)[0]
r_width = r_img.columns
r_height = r_img.rows

puts "Dimensions: #{r_width}x#{r_height}"
# Note: this is also included in hOCR output


# parse
h_page = Nokogiri::HTML(open(hocr_fname))

# h_el = ['ocr_carea', 'ocr_line', 'ocr_word']


h_areas = h_page.css('.ocr_carea')
puts "Areas: #{h_areas.length}"
h_areas.each do |h_area|
  
  h_lines = h_area.css('.ocr_line')
  puts "\tLines: #{h_lines.length}"
  
  h_lines.each do |h_line|
    
    h_words = h_line.css('.ocr_word')
    puts "\t\tWords: #{h_words.length}"
    
    # split rmagick into components
    
    # the name contains the index of the word in the page's sequence
    
    h_words.each do |h_word|
      word_name = h_word['id']
      word_dims = h_word['title'].scan(/\d+/).map{|d| d.to_i}

      x_word = h_word.css('.xocr_word').first
      x_word_content = x_word.text
      x_word_confidence = x_word['title'].match(/x_wconf (-?\d+)/)[0]

      
      word_x, word_y = word_dims[0..1]
      word_w = word_dims[2] - word_x
      word_h = word_dims[3] - word_y
      
      
      # rmagick::constitute
      word_pixels = r_img.dispatch(word_x, word_y, word_w, word_h, "RGB")
      word_img = Magick::Image.constitute(word_w, word_h, "RGB", word_pixels)
      
      line_filename = File.join(
        fname_output_dir,
        word_name + '---' + word_dims.map{|d| "%05d" % d.to_i}.join('_') + '.jpg' )
      
      word_img.strip!
      word_img.write(line_filename)

      puts line_filename
      
      
      
    end
    

  end
end




## produce json?




