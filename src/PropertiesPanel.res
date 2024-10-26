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

    React.useEffect1(() => {
      // Fetch the data from /examples and set the state when the promise resolves
      Fetch.fetchJson(`http://localhost:12346/examples`)
      |> Js.Promise.then_(examplesJson => {
        // NOTE: this uses an unsafe type cast, as safely parsing JSON in rescript is somewhat advanced.
        Js.Promise.resolve(setExamples(_ => Some(Obj.magic(examplesJson))))
      })
      // The "ignore" function is necessary because each statement is expected to return `unit` type, but Js.Promise.then return a Promise type.
      |> ignore
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

  let handleChange = (
    ~key: string,
    ~newValue: string,
    ~dimensions,
    ~setDimensions,
    ~dimension_type,
  ) => {
    // Naive validation to prevent the user from entering a number greater than 9999
    let validatedValue = Belt.Int.fromString(newValue) > Some(9999) ? "9999" : newValue
    setDimensions(prevDimensions =>
      switch key {
      | "margin_top" => {
          ...prevDimensions,
          margin_top: validatedValue,
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

  // Semi-hacky way to ensure that our blank input only reverts to "auto" when the user clicks away from it. If I did it in handleChange, it would revert to "auto" on every keystroke when the input is blank. Also, Placing api calls to our handleBlur manager helps prevent needless db operations.
  let handleBlur = (
    ~key: string,
    ~newValue: string,
    ~dimensions,
    ~setDimensions,
    dimension_type,
  ) => {
    let validatedValue = Belt.Int.fromString(newValue) > Some(9999) ? "9999" : newValue
    let value = validatedValue === "" ? "auto" : validatedValue

    setDimensions(prevDimensions =>
      switch key {
      | "top" => {...prevDimensions, top: value, dimension_type: dimension_type}
      | "bottom" => {...prevDimensions, bottom: value, dimension_type: dimension_type}
      | "left" => {...prevDimensions, left: value, dimension_type: dimension_type}
      | "right" => {...prevDimensions, right: value, dimension_type: dimension_type}
      | _ => prevDimensions
      }
    )
  }

  // purposefully only accepts px or % , if more formats were used this would change from a button to a dropdown
  let handleUnitChange = (~key: string, ~dimensions, ~setDimensions, dimension_type) => {
    setDimensions(prevDimensions =>
      switch key {
      | "top" => {
          ...prevDimensions,
          top_unit: prevDimensions.top_unit === "px" ? "%" : "px",
          dimension_type: dimension_type,
        }
      | "bottom" => {
          ...prevDimensions,
          bottom_unit: prevDimensions.bottom_unit === "px" ? "%" : "px",
          dimension_type: dimension_type,
        }
      | "left" => {
          ...prevDimensions,
          left_unit: prevDimensions.left_unit === "px" ? "%" : "px",
          dimension_type: dimension_type,
        }
      | "right" => {
          ...prevDimensions,
          right_unit: prevDimensions.right_unit === "px" ? "%" : "px",
          dimension_type: dimension_type,
        }
      | _ => prevDimensions
      }
    )
  }
}

// I Elected to keep everything in a monolithic file for ease of demonstration.
// Actually, I was originally just planning to use some prop drilling to move our database row's id around for upserts, but decided to use context after realising that i'd actually have to go just deep enough for context to be worth it. Also, I was interested in seeing how using Context would feel.
module DimensionContext = {
  type server_dimension_context = {
    currentRow: DimensionHandlers.serverDimension,
    setCurrentRow: (DimensionHandlers.serverDimension => DimensionHandlers.serverDimension) => unit,
    // updateColumn: (~key: string, ~newValue: string) => void,
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

module DimensionInput = {
  @react.component
  let make = (~value, ~onBlur, ~unit, ~onChange, ~onUnitChange, ~dimensionKey) => {
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
          onBlur(~key=dimensionKey, ~newValue=ReactEvent.Focus.target(event)["value"])
        }}
        value
        onChange={event =>
          onChange(~key=dimensionKey, ~newValue=ReactEvent.Form.target(event)["value"])}
        onKeyDown={handleKeyDown}
      />
      {
        // Causes some  Layout shift, can solve this with opacity or by placing the button in the input, but judged this wasn't a showstopper for a demo. Also, the actual UI's a bit off but just wanted an approximation since the functionality was more the focus.
        isFocused || value !== "auto"
          ? <button
              className="Dimension-button"
              disabled={!isFocused}
              onClick={_ => onUnitChange(~key=dimensionKey)}>
              {unit->React.string}
            </button>
          : React.null
      }
    </label>
  }
}

module MarginSelector = {
  @react.component
  let make = () => {
    let (margin, setMargin) = React.useState(() => DimensionHandlers.createInitialState())
    let {currentRow, setCurrentRow} = React.useContext(DimensionContext.context)

    Js.log(currentRow)
    // Elected to do one layer of state being sent as props due to the fact that this data will only go one child deep. However, if this were in a more complex tree, I would consider using a more comprehensive state management solution like  zustand, context, reduxv etc. This would also work more hand in hand with authentication in production level project, since we'd be able to easily track our current project.
    // let (serverDimensions, setServerDimensions) = React.useState(
    //   DimensionHandlers.createInitialState(),
    // )

    // let handleChange = (~key: string, ~newValue: string) => {
    //   Js.log("handleChange")
    //   DimensionHandlers.handleChange(
    //     ~key,
    //     ~newValue,
    //     ~dimensions=margin,
    //     ~setDimensions=setMargin,
    //     ~dimension_type="margin",
    //   )
    // }

    // let handleBlur = (~key: string, ~newValue: string) => {
    //   DimensionHandlers.handleBlur(
    //     ~key,
    //     ~newValue,
    //     ~dimensions=margin,
    //     ~setDimensions=setMargin,
    //     ~dimension_type="margin",
    //   )
    // }

    // let handleUnitChange = (~key: string) =>
    //   DimensionHandlers.handleUnitChange(
    //     ~key,
    //     ~dimensions=margin,
    //     ~setDimensions=setMargin,
    //     ~dimension_type="margin",
    //   )

    //  <fieldset className="MarginSelector-container">
    //       <div className="MarginSelector-subwrapper">
    //         <div className="Dimension-centered">
    //           <DimensionInput
    //             value={margin.top}
    //             unit={margin.top_unit}
    //             onBlur={handleBlur}
    //             onChange={handleChange}
    //             onUnitChange={handleUnitChange}
    //             dimensionKey="top"
    //           />
    //         </div>
    //         <div className="Selector-row">
    //           <DimensionInput
    //             value={margin.left}
    //             unit={margin.left_unit}
    //             onBlur={handleBlur}
    //             onChange={handleChange}
    //             onUnitChange={handleUnitChange}
    //             dimensionKey="left"
    //           />
    //           <DimensionInput
    //             value={margin.right}
    //             unit={margin.right_unit}
    //             onBlur={handleBlur}
    //             onChange={handleChange}
    //             onUnitChange={handleUnitChange}
    //             dimensionKey="right"
    //           />
    //         </div>
    //         <div className="Dimension-centered">
    //           <DimensionInput
    //             value={margin.bottom}
    //             unit={margin.bottom_unit}
    //             onBlur={handleBlur}
    //             onChange={handleChange}
    //             onUnitChange={handleUnitChange}
    //             dimensionKey="bottom"
    //           />
    //         </div>
    //         <PaddingSelector serverDimensions setServerDimensions />
    //       </div>
  }
}

module PaddingSelector = {
  type padding = DimensionHandlers.dimensions
  @react.component
  let make = (~serverDimensions, ~setServerDimensions) => {
    let (padding, setPadding) = React.useState(() => DimensionHandlers.createInitialState())

    // let handleChange = (~key: string, ~newValue: string) =>
    //   DimensionHandlers.handleChange(
    //     ~key,
    //     ~newValue,
    //     ~dimensions=padding,
    //     ~setDimensions=setPadding,
    //     ~dimension_type="padding",
    //   )

    // let handleBlur = (~key: string, ~newValue: string) =>
    //   DimensionHandlers.handleBlur(
    //     ~key,
    //     ~newValue,
    //     ~dimensions=padding,
    //     ~setDimensions=setPadding,
    //     ~dimension_type="padding",
    //   )

    // let handleUnitChange = (~key: string) =>
    //   DimensionHandlers.handleUnitChange(
    //     ~key,
    //     ~dimensions=padding,
    //     ~setDimensions=setPadding,
    //     ~dimension_type="padding",
    //   )

    // <fieldset className="PaddingSelector-container">
    //   <div className="Dimension-centered">
    //     <DimensionInput
    //       value={padding.top}
    //       unit={padding.top_unit}
    //       onBlur={handleBlur}
    //       onChange={handleChange}
    //       onUnitChange={handleUnitChange}
    //       dimensionKey="top"
    //     />
    //   </div>
    //   <div className="Selector-row">
    //     <DimensionInput
    //       value={padding.left}
    //       unit={padding.left_unit}
    //       onBlur={handleBlur}
    //       onChange={handleChange}
    //       onUnitChange={handleUnitChange}
    //       dimensionKey="left"
    //     />
    //     <DimensionInput
    //       value={padding.right}
    //       unit={padding.right_unit}
    //       onBlur={handleBlur}
    //       onChange={handleChange}
    //       onUnitChange={handleUnitChange}
    //       dimensionKey="right"
    //     />
    //   </div>
    //   <div className="Dimension-centered">
    //     <DimensionInput
    //       value={padding.bottom}
    //       unit={padding.bottom_unit}
    //       onBlur={handleBlur}
    //       onChange={handleChange}
    //       onUnitChange={handleUnitChange}
    //       dimensionKey="bottom"
    //     />
    //   </div>
    // </fieldset>
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
