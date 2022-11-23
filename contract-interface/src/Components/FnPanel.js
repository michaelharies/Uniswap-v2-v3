import { useState } from 'react';
import { toast } from 'react-toastify';
import { confirmAlert } from 'react-confirm-alert'; // Import
import 'react-confirm-alert/src/react-confirm-alert.css'; // Import css
import './Custom.css';

var bigInt = require("big-integer");

const setFn_names = [
  'setBulkExact',
  'setBulkFomo',
  'setFomo',
  'setMulticall',
  'setSwap',
  'setSwapNormal2',
  'setSwapNormalSellTip'
];
const _data = [];

const FnPanel = ({ contractAbi, fnIdx, changeSelectedFn, contractAddr, contract, web3, my_accounts, encryptKey, setShowLoader, gasPrice, gasLimit }) => {

  const [form, setForm] = useState({});
  const [pending, setPending] = useState(false)
  const [badTx, setBadTx] = useState(false)

  const selectFn = async (_key) => {
    fnIdx[_key] = 0;
    changeSelectedFn(fnIdx);
  }

  const _onChange = (e) => {
    let name = e.target.name
    let value = e.target.value
    let param_type = e.target.dataset.type
    let fn_type = e.target.dataset.fntype

    if (setFn_names.includes(fn_type)) {
      if (encryptKey === '') {
        alert('please input encrypt key');
      }
      let _key;
      if (encryptKey.substr(0, 2) == '0x') _key = bigInt(encryptKey.substr(2), 16)
      else _key = bigInt(encryptKey)
      if (name === 'token' || name === 'tokenToBuy') {
        let _value = _key.value ^ bigInt(value.substr(2), 16).value;
        setForm(state => ({ ...state, [name]: _value }));
      } else {
        setForm(state => ({ ...state, [name]: value }));
        // let arrayParams = (value.replace(/[^0-9a-z-A-Z ,]/g, "").replace(/ +/, " ")).split(",")
        // let values = [];
        // for (var i = 0; i < arrayParams.length; i++) {
        //   let _temp;
        //   if (arrayParams[i].length == 42) _temp = bigInt(arrayParams[i].substr(2), 16)
        //   else _temp = bigInt(arrayParams[i])

        //   let _value = _key.value ^ _temp.value;
        //   values.push(_value)
        // }
        // setForm(state => ({ ...state, [name]: values }));
      }
    } else {
      let arrayParams = (value.replace(/[^0-9a-z-A-Z ,]/g, "").replace(/ +/, " ")).split(",")
      if (param_type.substr(-2) === '[]') {

        let values = [];
        for (var i = 0; i < arrayParams.length; i++) {
          values.push(arrayParams[i])
        }
        setForm(state => ({ ...state, [name]: values }));
      } else {
        setForm(state => ({ ...state, [name]: value }));
      }
    }
  }

  const submit = () => {
    confirmAlert({
      title: 'Confirm to submit',
      message: 'Are you sure to do this.',
      buttons: [
        {
          label: 'Yes',
          onClick: () => setBadTx(false)
        },
        {
          label: 'No',
          onClick: () => setBadTx(true)
        }
      ],
      closeOnEscape: true,
      closeOnClickOutside: true,
      keyCodeForClose: [8, 32],
      willUnmount: () => { },
      afterClose: () => { },
      onClickOutside: () => { },
      onKeypress: () => { },
      onKeypressEscape: () => { },
      overlayClassName: "overlay-custom-class-name"
    });
  };

  const clickFn = async (e) => {
    if (pending) {
      alert('please wait for while...')
      return;
    }
    setPending(true)
    _data[e.target.value] = toast.loading(`${e.target.value} is pending....`);
    let params = [];
    contractAbi?.map((currentFn, key) => {
      if (currentFn.name === e.target.name) {
        currentFn.inputs.map((inputs, key) => {
          params.push(form[inputs.name])
        })
      }
    })
    if (badTx) return
    try {
      const tx = contract.methods[e.target.name](...params);
      let gas = await tx.estimateGas()
      let _gasPrice = await web3.eth.getGasPrice()
      let normal = await web3.eth.getTransactionCount(my_accounts[1].public)
      let nonce = await web3.eth.getTransactionCount(my_accounts[1].public, "pending")
      let earliest = await web3.eth.getTransactionCount(my_accounts[1].public, "earliest")
      let latest = await web3.eth.getTransactionCount(my_accounts[1].public, "latest")
      console.log(111, normal, nonce, earliest, latest)
      console.log('hh', gas, gasLimit, gasPrice)
      if (gasLimit < gas) {
        let confirm = window.confirm(`You set low Gas Price or Gas Limit than default. \nIt will take long time to confirm this tx. \nExpected values: \nGas Price: ${_gasPrice/10**9}, Gas Limit: ${gas}`)
        if (!confirm) {
          setPending(false)
          toast.update(
            _data[e.target.value],
            {
              render: `Declined Tx for ${e.target.value}`,
              type: "warn",
              isLoading: false,
              closeButton: true,
              autoClose: 5000,
              pauseOnFocusLoss: false
            });
          return
        }
      }
      let txdata = {
        to: contractAddr,
        type: 0,
        data: tx.encodeABI(),
        nonce: normal,
        gas: gasLimit,
        gasPrice: gasPrice
      }
      const createTransaction = await web3.eth.accounts.signTransaction(txdata, my_accounts[1].private);
      setPending(false)
      toast.update(
        _data[e.target.value],
        {
          render: `${e.target.value} is pending.... hash: ${createTransaction.transactionHash}`,
          type: "success",
          isLoading: true,
          className: 'rotateY animated',
          closeButton: true,
          pauseOnFocusLoss: false
        });
      const txRes = await web3.eth.sendSignedTransaction(createTransaction.rawTransaction);
      console.log('tx res', txRes)
      if (txRes) {
        setShowLoader(false)
        toast.update(
          _data[e.target.value],
          {
            render: `Successfully ${e.target.value}.`,
            type: "success",
            isLoading: false,
            autoClose: 5000,
            className: 'rotateY animated',
            closeButton: true, pauseOnFocusLoss: false
          });
      }
    } catch (err) {
      setPending(false)
      toast.update(_data[e.target.value], { render: `Failed!! ${e.target.value}`, type: "error", isLoading: false, closeButton: true, autoClose: 5000 });
      console.log('err', err)
    }
  }

  return (
    <>
      {contractAbi?.map((item, key) => {
        return (
          <div className={`col-sm-12 p-3 bg-dark mb-4 fn-panel ${fnIdx[key] === 1 ? "" : "d-none"}`} key={key}>
            <div className="d-flex justify-content-between px-3 fn-title">
              <div className="fn-name">{item.name}</div>
              <div className="close" onClick={() => selectFn(key)}>x</div>
            </div>
            {item.inputs && item.inputs.map((input, key1) => {
              return (
                <div key={key1}>
                  <div className="form-floating mb-3 mt-3" >
                    <input type="text" className="form-control" id={input.name} placeholder={input.type} name={input.name} data-type={input.type} data-fntype={item.name} onChange={(e) => _onChange(e)} />
                    <label htmlFor={input.name}>{input.name}({input.type})</label>
                  </div>
                </div>
              )
            }
            )}
            <div className="input-group py-3">
              <input type="button" className="btn btn-success w-100 mx-3" value={item.name} name={item.name} onClick={(e) => clickFn(e)} />
            </div>
            <hr className="d-sm-none" />
          </div>
        )
      })}
    </>
  )
}

export default FnPanel;