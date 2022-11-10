import { useState } from "react";
import FnPanel from "./FnPanel";
import FunctionTable from "./FunctionTable";

const Home = () => {

  const [contractAbi, setContractAbi] = useState([])
  const [selected, setSelectedFn] = useState([])
  const [fnIdx, setFnIdx] = useState([])

  const getAbi = (abi) => {
    try {
      let newArr = []
      let ABI = JSON.parse(abi)
      let _writeActions = ABI.filter((method, index) => {
        if (method.type == 'function') {
          newArr.push(0)
          setFnIdx(newArr)
        }
        return method.type === "function"
      });
      setContractAbi(_writeActions);
    } catch (err) {
      console.log('err', err)
      setContractAbi([]);
      setSelectedFn([])
    }
  }

  const changeSelectedFn = (_newAddr) => {
    setFnIdx(_newAddr)
    let _selected = contractAbi.filter((method, index) => {
      return _newAddr[index] == 1
    })
    setSelectedFn(_selected)
  }

  return (
    <>
      <div className="p-4 bg-primary text-white text-center">
        <h1>Smart Contract UI</h1>
        {/* <p>Set the parameters for swap functions</p> */}
      </div>

      <div className="container mt-5">
        <div className="row">
          <div className="col-md-5 col-lg-6">
            <div className="container">
              <form className="form-inline bg-dark p-4">
                <div className="form-group row mb-3 ">
                  <label htmlFor="address" className="col-sm-2 col-form-label">Address</label>
                  <div className="col-sm-10">
                    <input type="text" className="form-control" id="address" placeholder="address" />
                  </div>
                </div>
                <div className="form-group row mb-3 ">
                  <label htmlFor="address" className="col-sm-2 col-form-label">Abi</label>
                  <div className="col-sm-10">
                    <textarea type="text" className="form-control" id="address" placeholder="Input contract abi" onChange={(e) => getAbi(e.target.value)} />
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
            <div className="row">
              <FnPanel
                contractAbi={contractAbi}
                fnIdx={fnIdx}
                changeSelectedFn={changeSelectedFn}
              />
            </div>
          </div>

        </div>
      </div>

      <div className="mt-5 p-4 bg-dark text-white text-center">
        <p>@copyright 2022</p>
      </div>
    </>
  )
}

export default Home;