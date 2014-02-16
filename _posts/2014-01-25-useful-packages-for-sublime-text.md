---
layout: post
title: Useful packages for Sublime Text
categories:
- blog
- tool
---

[Sublime Text](http://www.sublimetext.com/) is an extremely powerful text editor. Currently I use [Sublime Text 3](http://www.sublimetext.com/3) and quite enjoy its simplicity and extensibility. In this blog, I would like to introduce some of my favorite packages that leverage my productivity.

# Package Control

Sublime Text is by default equipped with its package manager: [Package Control](https://sublime.wbond.net/). If you need to extend the original simple code editor, you can go to `View > Show Console` and run a block of code provided [here](https://sublime.wbond.net/installation) according to your version of Sublime Text. Once you install this package manager, the whole world of wonderful packages are open to you.

It is very easy to install a package from the repositories. Just press  `Ctrl+Alt+P` , type `Install` and you will be directed to `Package Control: Install Package` command. Now press `Enter` and you will find a very long list of packages available. Once you choose a package and press `Enter` again, the package will be downloaded and enabled automatically.

# My Settings

You can customize your coding environment by installing packages or just modifying some settings. It is amazing that nearly all change in settings can take effect immediately.


## Theme

I use [Spacegray](http://kkga.github.io/spacegray/) theme for my Sublime Text 3. I like its design of simplicity that minimizes possible distraction from your work. To install it, just follow my previous instruction and choose `Spacegray` package, and modify `Preferences > Settings - User` by changing or adding `"theme": "Spacegray.sublime-theme"` to the settings. Once you save the configuration file, the changes will take effect.

## Color Scheme

The theme defines how Sublime Text should appear on the screen. But for code editing, it is helpful to set a friendly color scheme that defines how different elements in programming codes should appear on the screen. It defines the color, style of text, etc. 

I use [Tomorrow Night](https://sublime.wbond.net/packages/Tomorrow%20Color%20Schemes) color scheme. The way of installation is exactly the same. This time, you may choose the installed color scheme in `Preferences > Color Scheme > Tomorrow Color Schemes`.

## Settings

From my personal experience, a good appearance of code editor really improves the quality of my work. For example, an text editor with few colorful elements certainly distracts less than does one with many colorful tabs and buttons; A bunch of code with appropriate syntax highlighting certainly helps more than one with pure black text in white background and more than one with overused colors.

Here is my additional settings I find useful to make a good writing environment:

<pre><code>
{
    "caret_style": "solid",
    "font_face": "Source Code Pro",
    "font_options":
    [
        "subpixel_antialias"
    ],
    "font_size": 14,
    "highlight_line": true,
    "line_padding_bottom": 0,
    "line_padding_top": 0,
    "rulers":
    [
        85,
        120
    ],
    "tab_size": 4,
    "translate_tabs_to_spaces": true,
    "trim_trailing_white_space_on_save": true,
    "wide_caret": true,
    "word_wrap": true,
    "wrap_width": 80
}
</code></pre>

Please note that I use [Source Code Pro](http://www.google.com/fonts/specimen/Source+Code+Pro) font, any you may visit [here](http://sourceforge.net/projects/sourcecodepro.adobe/files/), choose the latest version of `FontsOnly` package to download, and extract the OTF or TTF fonts to the `Fonts` directory.

In addition, I take out the lines of theme and color scheme in the settings.

# Useful Packages

If you intensively use Sublime Text for coding editing, you will probably find these packages very useful:

- [SideBarEnhancements](https://sublime.wbond.net/packages/SideBarEnhancements): Provides enhancements to the operations on Sidebar of Files and Folders for Sublime Text.
- [BracketHighlighter](https://sublime.wbond.net/packages/BracketHighlighter): Bracket Highlighter matches a variety of brackets, and even custom brackets.
- [Clickable URLs](https://sublime.wbond.net/packages/Clickable%20URLs): This plugin underlines URLs in Sublime Text, and lets you open them with a keystroke (`Ctrl+Alt+Enter` by default).
- [Search in Project](https://sublime.wbond.net/packages/Search%20in%20Project): This plugin makes it possible to use various external search tools (grep, ack, ag, git grep, or findstr) to find strings aross your entire current Sublime Text project.
- [Markdown Editing](https://sublime.wbond.net/packages/MarkdownEditing): Provides a decent Markdown color scheme (light and dark) with more robust syntax highlighting and useful Markdown editing features for Sublime Text. 3 flavors are supported: Standard Markdown, GitHub flavored Markdown, MultiMarkdown.
- [SublimeLinter](https://sublime.wbond.net/packages/SublimeLinter): A framework for interactive code linting in the Sublime Text 3 editor. (Each syntax needs to be installed separately)
- [SublimeCodeIntel](https://sublime.wbond.net/packages/SublimeCodeIntel): Full-featured code intelligence and smart auto-complete engine.
- [SublimeREPL](https://sublime.wbond.net/packages/SublimeREPL): Run an interpreter inside Sublime Text (Clojure, CoffeeScript, F#, Groovy, Haskell, Lua, MozRepl, NodeJS, Python + virtualenv, R, Ruby, Scala, ...)

With these packages, you will be able to make Sublime Text more of an IDE than a simple text editor. If you need more functionality, just search the repository. Enjoy it!