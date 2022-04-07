# f-nc (fklub nfc)
POC to read sector 15 of AAU study-cards for contact-less payment in [https://github.com/f-klubben/stregsystemet](https://github.com/f-klubben/stregsystemet).

Notice, this is strictly for educational purposes, no infringement of any rights intended.

## Prerequisites
- A NFC reader and adapter to interface with it
  - This POC uses a PN532 breakout (http://www.elechouse.com/elechouse/images/product/PN532_module_V3/PN532_%20Manual_V3.pdf) over UART USB adapter
  - `libnfc` installed to provide the `nfc-mfclassic` utility
- The A key (read key) for sector 15 of the AAU study-card. Can be obtained by way of hardnested mifare classic attack (https://github.com/nfc-tools/miLazyCracker).

## Usage
1. Dump a card `mfoc -k $A15_key -O card.dump`
2. Run `python3 f-nc.py`

## TODO
- Figure out how to sanitise dump for student information (UID, study-card-num)
  - Seems that `nfc-mfclassic` does not support simply being given the A15 key
- Rewrite in shell since this will be a very hot execute path (although usr time 48.69 millis sys time 55.27 millis out of 1.16s. so maybe not)