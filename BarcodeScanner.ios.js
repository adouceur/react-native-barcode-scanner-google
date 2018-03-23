import React, { Component } from 'react';
import { requireNativeComponent, NativeModules } from 'react-native';
import PropTypes from 'prop-types'

const BCTArray = [
 ["CODE_128", 0x0001],
 ["CODE_39", 0x0002],
 ["CODE_93", 0x0004],
 ["CODEBAR", 0x0008],
 ["DATA_MATRIX", 0x0010],
 ["EAN_13", 0x0020],
 ["EAN_8", 0x0040],
 ["ITF", 0x0080],
 ["QR_CODE", 0x0100],
 ["UPC_A", 0x0200],
 ["UPC_E", 0x0400],
 ["PDF417", 0x0800],
 ["AZTEC", 0x1000]
];

const BCTNumToStr = new Map();
BCTArray.forEach( (item) => { 
  const strK = item[1];
  const numV = item[0];
  BCTNumToStr.set(strK, numV);
});

export const BarcodeType = BCTArray.reduce(
  (curBCT, item) => {
    return {
      ...curBCT,
      [item[0]]: item[1]
    };
  },
  {}
);

class BarcodeScanner extends Component {
  _onBarcodeRead = (event) => {

    if (!this.props.onBarcodeRead) {
      return;
    }

    this.props.onBarcodeRead({
      data: event.nativeEvent.data, 
      type: BCTNumToStr.get(event.nativeEvent.type)
    });
  }

  render() {
    const props = {
        barcodeTypes: -1,
        ...this.props
    };

    return <NativeBarcodeScanner 
      {...props}
      onBarcodeRead = {this._onBarcodeRead}
    />
  }
}

BarcodeScanner.propTypes = {
  onBarcodeRead: PropTypes.func,
  barcodeTypes: PropTypes.number
};

const NativeBarcodeScanner = requireNativeComponent('BarcodeScannerView', BarcodeScanner);

export const toggleFlashOn = NativeModules.BarcodeScannerModule.toggleFlashOn;
export const toggleFlashOff = NativeModules.BarcodeScannerModule.toggleFlashOff;

export default BarcodeScanner;
