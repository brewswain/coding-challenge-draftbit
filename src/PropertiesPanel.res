open Belt

%raw(`require("./PropertiesPanel.css")`)
%raw(`require("./index.css")`)

module Collapsible = {
  @react.component
  let make = (~title, ~children) => {
    let (collapsed, toggle) = React.useState(() => false)

    <section className="Collapsible">
      <button className="Collapsible-button" onClick={_e => toggle(_ => !collapsed)}>
        <span> {React.string(title)} </span> <span> {React.string(collapsed ? "+" : "-")} </span>
      </button>
      {collapsed ? React.null : <div className="Collapsible-content"> {children} </div>}
    </section>
  }
}

// Code length became very much an issue when I had separate handlers in both the Padding and Margin Seleector modules, with a bunch of duplicated code. I solved this by Abstracting this logic and baseline state into its own util module. The tradeoff here is that now There's a bit of a clarity issue--This handler doesn't inherently differentiate between padding and margin. To solve this, I added an additional field: dimension_type. We'll use this parameter when making oor API call to determine which columns get updated. Realistically, having separate handlers would have been easier, but I was interested in seeing how I could solve this problem with a bit of abstraction.
module DimensionHandlers = {
  type serverDimension = {
    id: string,
    margin_top: string,
    margin_bottom: string,
    margin_left: string,
    margin_right: string,
    margin_top_unit: string,
    margin_bottom_unit: string,
    margin_left_unit: string,
    margin_right_unit: string,
    padding_top: string,
    padding_bottom: string,
    padding_left: string,
    padding_right: string,
    padding_top_unit: string,
    padding_bottom_unit: string,
    padding_left_unit: string,
    padding_right_unit: string,
    dimension_type: string,
  } // Type of the data returned by the /dimensions endpoint

  let createInitialServerState = () => {
    id: "0",
    margin_top: "auto",
    margin_bottom: "auto",
    margin_left: "auto",
    margin_right: "auto",
    margin_top_unit: "px",
    margin_bottom_unit: "px",
    margin_left_unit: "px",
    margin_right_unit: "px",
    padding_top: "auto",
    padding_bottom: "auto",
    padding_left: "auto",
    padding_right: "auto",
    padding_top_unit: "px",
    padding_bottom_unit: "px",
    padding_left_unit: "px",
    padding_right_unit: "px",
    dimension_type: "margin",
  }

  type dimensions = {
    top: string,
    bottom: string,
    left: string,
    right: string,
    top_unit: string,
    bottom_unit: string,
    left_unit: string,
    right_unit: string,
    dimension_type: string,
  }

  let createInitialState = () => {
    top: "auto",
    bottom: "auto",
    left: "auto",
    right: "auto",
    top_unit: "px",
    bottom_unit: "px",
    left_unit: "px",
    right_unit: "px",
    dimension_type: "padding",
  }

  let handleChange = (~key: string, ~newValue: string, ~setDimensions, ~dimension_type) => {
    // Naive validation to prevent the user from entering a number greater than 9999
    let validatedValue = Belt.Int.fromString(newValue) > Some(9999) ? "9999" : newValue

    // Verbose Switch statement to handle each key. I'm sure there's a more elegant way to do this.
    setDimensions(prevDimensions =>
      switch key {
      | "margin_top" => {
          ...prevDimensions,
          margin_top: validatedValue,
          dimension_type: dimension_type,
        }
      | "margin_bottom" => {
          ...prevDimensions,
          margin_bottom: validatedValue,
          dimension_type: dimension_type,
        }
      | "margin_left" => {
          ...prevDimensions,
          margin_left: validatedValue,
          dimension_type: dimension_type,
        }
      | "margin_right" => {
          ...prevDimensions,
          margin_right: validatedValue,
          dimension_type: dimension_type,
        }
      | "padding_top" => {
          ...prevDimensions,
          padding_top: validatedValue,
          dimension_type: dimension_type,
        }
      | "padding_bottom" => {
          ...prevDimensions,
          padding_bottom: validatedValue,
          dimension_type: dimension_type,
        }
      | "padding_left" => {
          ...prevDimensions,
          padding_left: validatedValue,
          dimension_type: dimension_type,
        }
      | "padding_right" => {
          ...prevDimensions,
          padding_right: validatedValue,
          dimension_type: dimension_type,
        }
      | "margin_top_unit" => {
          ...prevDimensions,
          margin_top_unit: newValue,
          dimension_type: dimension_type,
        }
      | "margin_bottom_unit" => {
          ...prevDimensions,
          margin_bottom_unit: newValue,
          dimension_type: dimension_type,
        }
      | "margin_left_unit" => {
          ...prevDimensions,
          margin_left_unit: newValue,
          dimension_type: dimension_type,
        }
      | "margin_right_unit" => {
          ...prevDimensions,
          margin_right_unit: newValue,
          dimension_type: dimension_type,
        }
      | "padding_top_unit" => {
          ...prevDimensions,
          padding_top_unit: newValue,
          dimension_type: dimension_type,
        }
      | "padding_bottom_unit" => {
          ...prevDimensions,
          padding_bottom_unit: newValue,
          dimension_type: dimension_type,
        }
      | "padding_left_unit" => {
          ...prevDimensions,
          padding_left_unit: newValue,
          dimension_type: dimension_type,
        }
      | "padding_right_unit" => {
          ...prevDimensions,
          padding_right_unit: newValue,
          dimension_type: dimension_type,
        }

      | _ => prevDimensions
      }
    )
  }
}


// I Elected to keep everything in a monolithic file for ease of demonstration.
// Actually, I was originally just planning to use some prop drilling to move our database row's id around for upserts, but decided to use context after realising that i'd actually have to go just deep enough for context to be worth it. Also, I was interested in seeing how using Context would feel in Rescript.
module DimensionContext = {
  type server_dimension_context = {
    currentRow: DimensionHandlers.serverDimension,
    setCurrentRow: (DimensionHandlers.serverDimension => DimensionHandlers.serverDimension) => unit,
  }

  let context = React.createContext(
    (
      {
        currentRow: DimensionHandlers.createInitialServerState(),
        setCurrentRow: _ => (),
      }: server_dimension_context
    ),
  )

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}

// This component provides a simplified example of fetching JSON data from
// the backend and rendering it on the screen.
module ViewExamples = {
  // Type of the data returned by the /examples endpoint
  type example = {
    id: int,
    some_int: int,
    some_text: string,
  }

  @react.component
  let make = () => {
    let (examples: option<array<example>>, setExamples) = React.useState(_ => None)
    let { setCurrentRow} = React.useContext(DimensionContext.context)

    // Have multiple calls here to show that the data is in fact being mutated correctly. Demonstration of our
    React.useEffect1(() => {
      // Fetch the data from /examples and log state when the promise resolves
      Fetch.fetchJson(`http://localhost:12346/examples`)
      |> Js.Promise.then_(examplesJson => {
        // NOTE: this uses an unsafe type cast, as safely parsing JSON in rescript is somewhat advanced.
        Js.Promise.resolve({
          
          Js.log(examplesJson)
          setExamples(_ => Some(Obj.magic(examplesJson)))
        })
      })
      // The "ignore" function is necessary because each statement is expected to return `unit` type, but Js.Promise.then return a Promise type.
      |> ignore

      // Mutate our data
      // Fetch.mutate(001, "test", ~method="POST", `http://localhost:12346/examples`)
      // |> Js.Promise.then_(examplesJson => {
      //   Js.Promise.resolve({
      //     Js.log(examplesJson)
      //     setExamples(_ => Some(Obj.magic(examplesJson)))
      //   })
      // })
      // |> ignore

      // dimensions block

      // Fetch the data from /dimensions and set the state when the promise resolves
      // Fetch.fetchJson(`http://localhost:12346/dimensions`)
      // |> Js.Promise.then_(currentRowJson => {
      //   Js.Promise.resolve(
      //   { 
      //                 Js.log(currentRowJson)
      //      setCurrentRow(Obj.magic(currentRowJson))
      //     }
      //   )
      // })
      // |> ignore

      // // Test Mutation
      // Fetch.mutate(
      //   ~new_value="1000",
      //   ~dimension_key="margin_top",
      //   ~method="PATCH",
      //   `http://localhost:12346/dimensions`,
      // )
      // |> Js.Promise.then_(currentRowJson => {
      //   Js.Promise.resolve({
      //     Js.log(currentRowJson)
      //     setCurrentRow(Obj.magic(currentRowJson))
      //   })
      // })
      // |> ignore

      None
    }, [setExamples])

    <div>
      {switch examples {
      | None => React.string("Loading examples....")
      | Some(examples) =>
        examples
        ->Js.Array2.map(example =>
          React.string(`Int: ${example.some_int->Js.Int.toString}, Str: ${example.some_text}`)
        )
        ->React.array
      }}
    </div>
  }
}




module DimensionInput = {
  @react.component
  let make = (~value, ~unit, ~onChange, ~dimensionKey) => {
    let (isFocused, setIsFocused) = React.useState(() => false)

    // LLM generated regex validation to ensure only numbers are inputted -- This is the one bit of LLM generated code I used since working out regex handling while learning rescript seemed like a rabbithole for something that could/should be a very concise solution.
    let handleKeyDown = event => {
      let key = ReactEvent.Keyboard.key(event)
      let allowedCharactersRegex = %re("/[0-9]|Backspace|Delete|ArrowLeft|ArrowRight/")

      if !Js.Re.test_(allowedCharactersRegex, key) {
        ReactEvent.Keyboard.preventDefault(event)
      }
    }

    <label
      className={`Dimension-input-container ${!isFocused && value !== "auto"
          ? "Dimension-input-container--active"
          : ""}`}
      onFocus={_ => setIsFocused(_ => true)}
      onMouseDown={event => {
        ReactEvent.Mouse.stopPropagation(event)
        ReactEvent.Mouse.preventDefault(event)
      }}
      onBlur={_ => setIsFocused(_ => false)}>
      <input
        className={`Dimension-input ${!isFocused && value !== "auto"
            ? "Dimension-input--active"
            : ""}`}
        onClick={event => {
          let input = ReactEvent.Mouse.currentTarget(event)
          input["select"](.)
        }}
        onBlur={event => {
          let targetValue = ReactEvent.Focus.target(event)["value"]
          let value = targetValue === "" ? "auto" : targetValue
          onChange(~key=dimensionKey, ~newValue=value)
        }}
        value
        onChange={event =>
          onChange(~key=dimensionKey, ~newValue=ReactEvent.Form.target(event)["value"])}
        onKeyDown={handleKeyDown}
      />
      {
        // Since I chose to only use 2 possible units, this button flow was chosen. Otherwise, if more formats were expected, a dropdown/select would work better.
        isFocused || value !== "auto"
          ? <button
              className="Dimension-button"
              disabled={!isFocused}
              onClick={_ =>
                onChange(~key=dimensionKey ++ "_unit", ~newValue=unit === "px" ? "%" : "px")}>
              {unit->React.string}
            </button>
          : React.null
      }
    </label>
  }
}

// Expect UI for this and MarginSelector to be slightly janky but functional
module PaddingSelector = {
  @react.component
  let make = () => {
    let {currentRow, setCurrentRow} = React.useContext(DimensionContext.context)

    let handleChange = (~key: string, ~newValue: string) => {
      DimensionHandlers.handleChange(
        ~key,
        ~newValue,
        ~setDimensions=setCurrentRow,
        ~dimension_type="padding",
      )
    }

    <div className="PaddingSelector-container">
      <div className="Dimension-centered">
        <DimensionInput
          value={currentRow.padding_top}
          unit={currentRow.padding_top_unit}
          onChange={handleChange}
          dimensionKey="padding_top"
        />
      </div>
      <div className="Selector-row">
        <DimensionInput
          value={currentRow.padding_left}
          unit={currentRow.padding_left_unit}
          onChange={handleChange}
          dimensionKey="padding_left"
        />
        <DimensionInput
          value={currentRow.padding_right}
          unit={currentRow.padding_right_unit}
          onChange={handleChange}
          dimensionKey="padding_right"
        />
      </div>
      <div className="Dimension-centered">
        <DimensionInput
          value={currentRow.padding_bottom}
          unit={currentRow.padding_bottom_unit}
          onChange={handleChange}
          dimensionKey="padding_bottom"
        />
      </div>
    </div>
  }
}

module MarginSelector = {
  @react.component
  let make = () => {
    let {currentRow, setCurrentRow} = React.useContext(DimensionContext.context)

    let handleChange = (~key: string, ~newValue: string) => {
      DimensionHandlers.handleChange(
        ~key,
        ~newValue,
        ~setDimensions=setCurrentRow,
        ~dimension_type="margin",
      )
    }

    <div className="MarginSelector-container">
      <div className="MarginSelector-subwrapper">
        <div className="Dimension-centered">
          <DimensionInput
            value={currentRow.margin_top}
            unit={currentRow.margin_top_unit}
            onChange={handleChange}
            dimensionKey="margin_top"
          />
        </div>
        <div className="Selector-row">
          <DimensionInput
            value={currentRow.margin_left}
            unit={currentRow.margin_left_unit}
            onChange={handleChange}
            dimensionKey="margin_left"
          />
          <DimensionInput
            value={currentRow.margin_right}
            unit={currentRow.margin_right_unit}
            onChange={handleChange}
            dimensionKey="margin_right"
          />
        </div>
        <div className="Dimension-centered">
          <DimensionInput
            value={currentRow.margin_bottom}
            unit={currentRow.margin_bottom_unit}
            onChange={handleChange}
            dimensionKey="margin_bottom"
          />
        </div>
        <PaddingSelector />
      </div>
    </div>
  }
}

@genType @genType.as("PropertiesPanel") @react.component
let make = () => {
  let (currentRowState, setCurrentRowState) = React.useState(() =>
    DimensionHandlers.createInitialServerState()
  )

  <aside className="PropertiesPanel">
    <DimensionContext.Provider
      value={
        DimensionContext.currentRow: currentRowState,
        DimensionContext.setCurrentRow: setCurrentRowState,
      }>
      <Collapsible title="Load examples"> <ViewExamples /> </Collapsible>
      <Collapsible title="Margins & Padding"> <MarginSelector /> </Collapsible>
      <Collapsible title="Size"> <span> {React.string("example")} </span> </Collapsible>
    </DimensionContext.Provider>
  </aside>
}
