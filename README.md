# GEDCOM 5.5 Driver for Objective-C

This is a driver which parses GEDCOM 5.5.1 data into traversable structures.

## Already Implemented

* **Read**: All data is parsed into a generic kind of container, `FSGEDCOMSturcture`. Using this container, it is actually possible to do anything in GEDCOM. It's not terribly fancy, but using Key-Value Coding (and particularly Key-Value Paths and `NSPredicate`) you can perform almost any kind of query operation. It sucessfully handles `CONT` and `CONC` lines as well.
* **Read**: Individuals and Families are parsed into their own special containers, and are linked together using weak-references.

## Pending Implementation

* **Read**: Basic data fields should be pulled into specialized containers for maximal code re-use and for easier querying. It will also make it easier to programmatically construct GEDCOM data.
* **Emit**: A set of categories on FSGEDCOM classes to facilitate emitting data for use with New FamilySearch. So an `FSGEDCOMIndividual` could be transformed to a constituent set of assertions (represented as dictionaries and arrays).
* **Emit**: A set of categories on FSGEDCOM classes to facilitate emitting data for use with FamilySearch Conclusion Tree. This is kind of waiting on that API to stabilize.
* **Emit**: A GEDCOM 5.5.1 emitter is pending.

## Compliance

This parser tries its best to comply with the GEDCOM 5.5.1 standard, however there are a few considerations to keep in mind:

* All input must be UTF-8 encoded. ANSEL is not supported, and UTF-16 and UTF-32 are right out.
* This parser does not enforce line-length requirements. It will warn you when a line is too long, but it will otherwise perform as if the (brain-dead) line-length requirement were not existant.
* This parser is not quite "rigorously tested." If it breaks, send NSError an example GEDCOM with which to duplicate the problem!
* There is no DSL to programmatically create a GEDCOM in memory. So doing that is going to be incredibly difficult and probably frustrating. This said, it's much easier to use your own conclusion objects and tell them how to create pieces of GEDCOM, rather than rely on a single monolithic function. Think OOP!

## Requirements

* A functional Objective-C 2.0 Non-fragile runtime with C blocks support.
* Apple Foundation - GNUStep or others could function, but it's not supported.

Generally, if you're running Apple Xcode 4.2 or better, you're covered.