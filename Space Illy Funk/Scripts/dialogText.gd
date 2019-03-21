extends RichTextLabel

"""
to do:
	
	Maybe do a bug report for godot on the custom size font bug.
	
donezo:
	Create system for closing dialog box once the text is done with. 
	
	Page jumps are working now, but meta-click jumps are spitting out whole lines, rather than typing char by char
		probably related to the code that fills text out on click; doing the meta and 'typing' stuff at once?
			I was right, and can be fixed by giving main click func a !metahover param, but now you can't speed
			up text if you click where a meta is/will be. Minor, but should fix.
				solved by just replicating behaviour into meta_click func
	
	Clean things up; unneeded variables from previous methods need nixxin'
	
	I need to search through the pageJumps.x array to check if it matches the current page so I have a flexible system
		Look into the array.find() func
		
	Check out richTextLabel BBcode tutorial in godot (helpful enough)
	
	Meta text underlines are broken (won't turn off) should be fixed in next godot update (Reminder)
"""
onready var dialogRoot = get_parent().get_parent()

var fileName

var words = []
var page = 0

#pageBreak keeps track of where a jump is from and to, respectively. (will need revising)
var pageBreak = Vector2(0,0)
var jumpFrom = []
var jumpTo = []

var metaHover = false


func _ready():
	fileName = dialogRoot.fileName
	getText(fileName)
	displayText(words,page)
	visible_characters = 0

func _process(delta):
	if Input.is_action_just_pressed("LeftMouseDown") && !metaHover: 
		if visible_characters < get_total_character_count():
			visible_characters = get_total_character_count()
		elif jumpFrom.has(page):
			print(page)
			page = jumpTo[jumpFrom.find(page)] # ARRAYYSSS
			print(page)
			displayText(words,page)
			visible_characters = 0
		elif page < words.size() - 1: #Don't forget -1; bloody arrays WHATS WRONG WITH STARTING WITH 1? EHHHH?
			page += 1
			displayText(words,page)
			visible_characters = 0
		else: get_parent().get_parent().queue_free() #Closes dialog box

func displayText(_words, _page):
	set_bbcode(_words[_page])

func getText(_fileName, _index = 0):
	var _file = File.new()
	_file.open(_fileName,1)
	var _cursorPos
	while !_file.eof_reached():
		var _line = _file.get_line()
		_line = _line.replace("\\n","\n") # Remember to assign; just '_line.replace("\\n","\n") will NOT work
		if "pg" in _line: 
			jumpFrom.append(_index) #Marks which line is the jump point
			jumpTo.append(int(_line.substr(_line.find("pg") + 2, 1))) # Marks which line to jump to
			# (+2 because the page # will be 2 chars after pg)^
			print(jumpFrom,jumpTo)
			_line.erase(_line.find("pg"),3) # Erases the Pg# bit form string. Weirdly this WON'T work with an assign...
		if !_line.empty(): #If this isn't here it will insert a blank entry to the array
			words.append(_line)
			_index += 1
		_cursorPos = _file.get_position()
	_index = 0 # Just in case; hopefully won't break anything
	_file.close()


func _on_Timer_timeout():
	if visible_characters < get_total_character_count():
		visible_characters += 1


func _on_dialogText_meta_clicked(meta):
	if visible_characters == get_total_character_count():
		visible_characters = 0
		page = int(meta)
		displayText(words,int(meta))
	else: visible_characters = get_total_character_count() # Keeps it possible to speed text along wihtout jumping options

	
func _on_dialogText_meta_hover_started(meta):
	metaHover = true
func _on_dialogText_meta_hover_ended(meta):
	metaHover = false
