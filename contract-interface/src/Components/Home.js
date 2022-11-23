import { useEffect, useState } from "react";
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import Web3 from "web3";
import { my_accounts, rpc_goerli } from "../config/config";
import ContractAbi from '../config/contractAbi.json';
import './Custom.css';
import FnPanel from "./FnPanel";
import FunctionTable from "./FunctionTable";

const Home = () => {

  const web3 = new Web3(rpc_goerli.https);
  const [contractAddr, setContractAddr] = useState('')
  const [contractAbi, setContractAbi] = useState([])
  const [contract, setContract] = useState({})
  const [selected, setSelectedFn] = useState([])
  const [fnIdx, setFnIdx] = useState([])
  const [encryptKey, setEncryptKey] = useState('')
  const [showLoader, setShowLoader] = useState(false)
  const [gasPrice, setGasPrice] = useState(5)
  const [gasLimit, setGasLimit] = useState(30000)

  useEffect(() => {
    setContractAddr(localStorage.getItem('address'))
    setEncryptKey(localStorage.getItem('key'))
  }, [])

  useEffect(() => {
    if (contractAddr !== "" && contractAddr.length > 40) {
      const _contract = new web3.eth.Contract(ContractAbi, contractAddr, { from: my_accounts[1].public });
      setContract(_contract)
      getAbi(ContractAbi)
    }
  }, [contractAddr])

  const getAbi = (abi) => {
    try {
      let newArr = []
      let _writeActions = abi.filter((method, index) => {
        if (method.type === 'function') {
          newArr.push(0)
          setFnIdx(newArr)
        }
        return method.type === "function" && (method.stateMutability === "payable" || method.stateMutability === "nonpayable");
      });
      localStorage.setItem("abi", JSON.stringify(_writeActions))
      setContractAbi(_writeActions);
    } catch (err) {
      console.log('adf', err)
      setContractAbi([]);
      setFnIdx([])
    }
  }

  const changeSelectedFn = (_newAddr) => {
    setFnIdx(_newAddr)
    let _selected = contractAbi.filter((method, index) => {
      return _newAddr[index] === 1
    })
    setSelectedFn(_selected)
  }

  return (
    <>
      <div className="p-4 text-white text-center">
        <h1>Smart Contract UI</h1>
      </div>
      <div className="container mt-5">
        <div className="row">
          <div className="col-md-5 col-lg-6">
            <div className="container">
              <form className="form-inline bg-dark p-4 input-form">
                <div className="form-group row mb-3 ">
                  <label htmlFor="address" className="col-sm-2 col-form-label">Address</label>
                  <div className="col-sm-10">
                    <input type="text" className="form-control" id="address" placeholder="Contract address" value={contractAddr} onChange={(e) => {
                      setContractAddr(e.target.value)
                      localStorage.setItem("address", e.target.value)
                    }} required />
                  </div>
                </div>
                {/* <div className="form-group row mb-3 ">
                  <label htmlFor="address" className="col-sm-2 col-form-label">Abi</label>
                  <div className="col-sm-10">
                    <textarea type="text" className="form-control" id="address" placeholder="Input contract abi"
                      value={JSON.stringify(contractAbi)}
                      onChange={(e) => {
                        getAbi(e.target.value)
                      }} />
                  </div>
                </div> */}
                <div className="form-group row mb-3 ">
                  <label htmlFor="key" className="col-sm-2 col-form-label">Key</label>
                  <div className="col-sm-10">
                    <input type="text" className="form-control" id="key" placeholder="Encrypt Key" value={encryptKey} onChange={(e) => {
                      localStorage.setItem('key', e.target.value)
                      setEncryptKey(e.target.value)
                    }} />
                  </div>
                </div>
              </form>
            </div>
            <FunctionTable
              contractAbi={contractAbi}
              changeSelectedFn={changeSelectedFn}
              fnIdx={fnIdx}
            />
          </div>
          <div className="col-md-7 col-lg-6">
            <div className="row justify-content-evenly bg-dark p-2 rounded-2 mb-4">
              <div className="col-md-6">
                <div className="form-group row">
                  <label htmlFor="gas" className="col-sm-6 col-form-label">GAS PRICE</label>
                  <div className="col-sm-6">
                    <input type="text" className="form-control" name="customGasPrice" value={gasPrice} onChange={(e) => { setGasPrice(e.target.value)}} id="gas" placeholder="20" />
                  </div>
                </div>
              </div>
              <div className="col-md-6">
                <div className="form-group row">
                  <label htmlFor="gas" className="col-sm-6 col-form-label">GAS LIMIT</label>
                  <div className="col-sm-6">
                    <input type="text" className="form-control" name="customGasPrice" value={gasLimit} onChange={(e) => {setGasLimit(eval(e.target.value)) }} id="gas" placeholder="20" />
                  </div>
                </div>
              </div>
            </div>
            <div className="row">
              <FnPanel
                contractAbi={contractAbi}
                fnIdx={fnIdx}
                changeSelectedFn={changeSelectedFn}
                contractAddr={contractAddr}
                contract={contract}
                web3={web3}
                my_accounts={my_accounts}
                encryptKey={encryptKey}
                setShowLoader={setShowLoader}
                gasPrice={gasPrice}
                gasLimit={gasLimit}
              />
            </div>
          </div>
        </div>
      </div>
      <div className={`loader ${showLoader ? "" : "d-none"}`} >
        <div className="container1">
          <div className="dash uno"></div>
          <div className="dash dos"></div>
          <div className="dash tres"></div>
          <div className="dash cuatro"></div>
        </div>
      </div>
      <ToastContainer />
    </>
  )
}

export default Home;