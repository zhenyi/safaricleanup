# Safaricleanup

Safaricleanup is a command line utility for clearing Safari’s browsing history, cache and cookies.

<br>
## Installation

1. Download the [zip file](https://github.com/zhenyi/safaricleanup/raw/gh-pages/safaricleanup.zip).
2. Extract it and copy `safaricleanup` into your `PATH` (e.g. `/usr/local/bin`).

<br>
## How I use it: automatically clear (some) cookies when quitting Safari

<br>
### 1. Create an Automator workflow

Open Automator and select “Service” from the menu.

![Create an Automator workflow](https://github.com/zhenyi/safaricleanup/raw/gh-pages/images/1.png)

<br>
### 2. Configure the service

At the top of the new document, set the options to “no input” and “Safari.app”.

![Configure the service](https://github.com/zhenyi/safaricleanup/raw/gh-pages/images/2.png)

<br>
### 3. Add the “Quit Application” action

Drag the “Quit Application” action into the document and choose “Safari.app” from the drop-down menu in the action.

![Add the “Quit Application” action](https://github.com/zhenyi/safaricleanup/raw/gh-pages/images/3.png)

<br>
### 4. Add the “Run Shell Script” action

Drag a “Run Shell Script” action, and paste in the following:
`/usr/local/bin/safaricleanup -s -c -t -k --only=facebook.com,twitter.com`
<br>
See `safaricleanup -h` for the full list of options.

![Add the “Run Shell Script” action](https://github.com/zhenyi/safaricleanup/raw/gh-pages/images/4.png)

Hit Save and name the service something like “Clear Data and Quit Safari”.

<br>
### 5. Remap the “Quit Safari” menu item

1. Go to System Preferences > Keyboard > Shortcuts.
2. Choose “App Shortcuts” in the sidebar.
3. Click the “+” button.
4. Set it to “Safari.app” and enter “Quit Safari” (it’s case sensitive) as the Menu Title.

![5. Remap the “Quit Safari” menu item](https://github.com/zhenyi/safaricleanup/raw/gh-pages/images/5.png)

<br>
### 6. Map Cmd-Q to the newly created service

1. In the Keyboard Shortcuts preference pane, choose “Services” in the sidebar.
2. Find the newly created service and then double-click to the right of it.
3. Set the shortcut and press return. Make sure it’s checked.

![Map Cmd-Q to the newly created service](https://github.com/zhenyi/safaricleanup/raw/gh-pages/images/6.png)
