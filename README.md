# Welcome to MindApp

## About
The MindApp project includes final projects of a few people and still counting. The core purpose of MindApp is to track, show and help improve mental health of its users.

The initial version, created by Michael Slavev and Daniel Davidik, enables users to view their health statistics, especially with regards to heart data (HR, HRV,...) fetched from the Apple Health app as well as improve these statistics by a set of provided activities that the users can practice.

The Gen2 version, currently in development by Jan Gutwirth and Jan Pfeiffer, plans to bring LLM capabilities for advanced reporting and new self reflection as well as an entirely new part of the app focusing on exercises, both to further improve health statistics provided to the users and improving the health of the users.

## Build info
### Building the app
The app requires at least iOS 16.0 to run, when building on XCode 16 it has no issues, should probably run on some older versions as well, but no guarantees.
### Building documentation
To build the documentation, you need to go to XCode > Product > Build Documentation - this should build the whole project again and with that, build the documentation and pop-up in a new window with the built Apple-style documentation.

Since this step builds documentation for the entire project including it's dependencies, it might take a few moments for it to build, because it's also building documentation for Supabase, AlertToast, etc. which might be relevant for the app's documentation.

The documentation is led in DocC way, you can search for more information if you want to, it shouldn't be too hard to find them.

## Documentation
Currently, no documentation is available online. The good news is that once you clone the project and follow the steps [above](#building-documentation), it shouldn't be any problem to build the documentation with the project and there you should hopefully find all the info you're searching for.

Please note that a good piece of the repository was developed by people who aren't active developers on this project anymore so although we have a good picture of what the code does, don't take everything you see in the docs with 100% accuracy.

### Adding new documentation
Once you get into the development yourself, please add new pieces of documentation with regards to the new pieces of code you add. In addition to that, please use the DocC documentation "framework"/"standard" as it is what's used in the rest of the project. You can find a lot of information about it online, but to start your way, you can click with cursor into a name of a class or a function in XCode and then click `⌘`+`⌥`+`/` (alternatively you can just right-click on the name of the func/whatever you want to comment, and select "Add Documentation") which should generate a basic comment in the code above the selected func / class / struct that should support the DocC format.

## UI Design
With the development of this project, a separate project for documenting and creating UI design in Figma is also being created and maintained. The Figma project is available [here](https://www.figma.com/design/2EJ8TgLNSYGK6748W3ZXXh/MindApp?node-id=0-1&t=hK5op5zMKNx1Zgob-1) and hopefully will be soon up-to-date and kept that way.

## Contributors
As mentioned in the [About](#about) section, the list of contributors includes following:

Michael Slavev

Daniel Davidik

Jan Gutwirth

Jan Pfeiffer

