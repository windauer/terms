# Terms

A database of terms drawn from the lists of terms and abbreviations in many volumes of the *Foreign Relations of the United States*. The application provides a searchable list of all entries. 

## Data sources

- [The _Foreign Relations of the United States (FRUS)_ series](https://history.state.gov/historicaldocuments) (see raw data at the [HistoryAtState/frus](https://github.com/HistoryAtState/frus) GitHub repository)

## Status

The data and app are very preliminary and subject to reorganization.

## Dependencies

- The data in the `data` collection is XML
- The application runs in [eXist](http://exist-db.org). Requires 3.0+.
- Building the installable package requires Apache Ant

## Installation

- Check out the repository
- Build the xar file(s) with following command:
    1. Single `xar` file: The `collection.xconf` will only contain the index, not any triggers!
      ```shell
      ant
      ```
      
- Upload build/terms-0.1.xar to eXist-db's Dashboard > Package Manager
- Open http://localhost:8080/exist/apps/terms
