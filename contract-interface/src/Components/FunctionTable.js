import './Custom.css';

const FunctionTable = ({ contractAbi, changeSelectedFn, fnIdx }) => {

  const selectFn = (_key) => {
    fnIdx[_key] = 1;
    changeSelectedFn(fnIdx);
  }

  return (
    <div className="container mt-3">
      {/* <p>Contract Functions:</p> */}
      <table className="table table-dark table-striped table-hover table-responsive-md table-borderless">
        <thead>
          <tr>
            <th scope='row'>No</th>
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          {
            contractAbi?.map((functions, key) => {
              return (
                <tr>
                  <td scope="row">{key}</td>
                  <td className="fn-name" onClick={() => {
                    selectFn(key)
                    // setSelectFn(functions.name, key)
                  }
                  } >{functions.name}</td>
                </tr>
              )
            })
          }
        </tbody>
      </table>
    </div>
  )
}

export default FunctionTable;