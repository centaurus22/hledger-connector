## 0.1.0

- Initial version.

## 0.2.0

- Change the account name from an Account object to a string.
- Check if the account name is empty.
- Change the file path to a string.
- Check if the file path is empty before opening the file for writing.
- Other improvements.

## 0.3.0

- I am happy to introduce the journal parser that reads a file and returns a Transaction object.
- I added a large list to the Readme where you can see which ledger journal feature is already supported.
- Improvements of other parts of the code.

## 0.4.0

- Add functions to directly convert transactions from a journal entry to an
      object and vice versa – without writing them to a file.
- Other Improvements
    * Improve the record structure: The `Amount` object no longer has
      subclasses. Instead, the optional `Symbol` is now a sealed class with the
      two subclasses `PrecedingSymbol` and `FollowingSymbol`.
    * Rename the `SubTransaction` object to `Posting`.
    * Shorten the name of the `Success` object to just `Ok`.
    * Improve the naming of the primary functions and use cases.
    * Further improvements.

## 0.5.0

- Add a function to convert a list of transactions to a string containing the
  corresponding journal entries.

## 0.6.0

- Remove the Error object and throw Errors and Exceptions instead. Keep the Ok
  object as a default return value for some functions, to be able to attach
  warnings to it.
- Add warning when a comment is ignored.
- Other improvements

## 0.6.1

- Fix regexp which parses the amount and symbol. In some cases the symbol could
not be parsed correctly.