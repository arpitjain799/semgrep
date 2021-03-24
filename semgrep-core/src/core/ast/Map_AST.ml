(* Yoann Padioleau
 *
 * Copyright (C) 2019 r2c
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
*)
open OCaml

open AST_generic

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(* hooks *)

type visitor_in = {
  kexpr: (expr  -> expr) * visitor_out -> expr  -> expr;
  kstmt: (stmt -> stmt) * visitor_out -> stmt -> stmt;

  kinfo: (tok -> tok) * visitor_out -> tok -> tok;
  kidinfo: (id_info -> id_info) * visitor_out -> id_info -> id_info;
}

and visitor_out = {
  vitem: item -> item;
  vprogram: program -> program;
  vexpr: expr -> expr;
  vany: any -> any;
}

let default_visitor =
  {
    kexpr   = (fun (k,_) x -> k x);
    kstmt   = (fun (k,_) x -> k x);
    kinfo   = (fun (k,_) x -> k x);
    kidinfo = (fun (k,_) x -> k x);
  }

let map_id x = x

let (mk_visitor: visitor_in -> visitor_out) = fun vin ->
  (* start of auto generation *)

  (* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_map.cmo  pr_o.cmo /tmp/xxx.ml  *)

  let rec map_tok v =
    (* old: Parse_info.map_info v *)
    let k x =
      match x with
        { Parse_info.token = v_pinfo;
          transfo = v_transfo;
        } ->
          let v_pinfo =
            (* todo? map_pinfo v_pinfo *)
            v_pinfo
          in
          (* not recurse in transfo ? *)
          { Parse_info.token = v_pinfo;   (* generete a fresh field *)
            transfo = v_transfo;
          }
    in
    vin.kinfo (k, all_functions) v

  and map_wrap:'a. ('a -> 'a) -> 'a wrap -> 'a wrap = fun _of_a (v1, v2) ->
    let v1 = _of_a v1 and v2 = map_tok v2 in (v1, v2)

  and map_bracket:'a. ('a -> 'a) -> 'a bracket -> 'a bracket =
    fun of_a (v1, v2, v3) ->
      let v1 = map_tok v1 and v2 = of_a v2 and v3 = map_tok v3 in (v1, v2, v3)

  and map_ident v = map_wrap map_of_string v

  and map_dotted_ident v = map_of_list map_ident v

  and map_qualifier = function
    | QDots v -> QDots (map_dotted_ident v)
    | QTop t -> QTop (map_tok t)
    | QExpr (e, t) -> let e = map_expr e in let t = map_tok t in QExpr(e, t)

  and map_module_name =
    function
    | FileName v1 -> let v1 = map_wrap map_of_string v1 in FileName v1
    | DottedName v1 -> let v1 = map_dotted_ident v1 in DottedName v1

  and map_resolved_name (v1, v2) =
    let v1 = map_resolved_name_kind v1 in
    let v2 = map_of_int v2 in
    (v1, v2)
  and map_resolved_name_kind =
    function
    | Local  -> Local
    | Param  -> Param
    | EnclosedVar  -> EnclosedVar
    | Global -> Global
    | ImportedEntity v1 -> let v1 = map_dotted_ident v1 in ImportedEntity v1
    | ImportedModule v1 ->
        let v1 = map_module_name v1 in ImportedModule v1
    | Macro -> Macro
    | EnumConstant -> EnumConstant
    | TypeName -> TypeName


  and map_name_ (v1, v2) =
    let v1 = map_ident v1 and v2 = map_name_info v2 in (v1, v2)
  and
    map_name_info {
      name_qualifier = v_name_qualifier;
      name_typeargs = v_name_typeargs
    } =
    let v_name_typeargs = map_of_option map_type_arguments v_name_typeargs in
    let v_name_qualifier = map_of_option map_qualifier v_name_qualifier
    in { name_qualifier = v_name_qualifier; name_typeargs = v_name_typeargs  }
  and map_id_info v =
    let k x =
      match x with
        { id_resolved = v_id_resolved; id_type = v_id_type;
          id_constness = v3
        } ->
          let v3 = map_of_ref (map_of_option map_constness) v3 in
          let v_id_type = map_of_ref (map_of_option map_type_) v_id_type in
          let v_id_resolved =
            map_of_ref (map_of_option map_resolved_name) v_id_resolved
          in
          { id_resolved = v_id_resolved; id_type = v_id_type;
            id_constness = v3
          }
    in
    vin.kidinfo (k, all_functions) v


  and map_xml {
    xml_kind = v_xml_tag;
    xml_attrs = v_xml_attrs;
    xml_body = v_xml_body
  } =
    let v_xml_body = map_of_list map_xml_body v_xml_body in
    let v_xml_attrs = map_of_list map_xml_attribute v_xml_attrs in
    let v_xml_tag = map_xml_kind v_xml_tag in
    { xml_kind = v_xml_tag; xml_attrs = v_xml_attrs; xml_body = v_xml_body }

  and map_xml_kind = function
    | XmlClassic (v0, v1, v2, v3) ->
        let v0 = map_tok v0 in
        let v1 = map_ident v1 in
        let v2 = map_tok v2 in
        let v3 = map_tok v3 in
        XmlClassic (v0, v1, v2, v3)
    | XmlSingleton (v0, v1, v2) ->
        let v0 = map_tok v0 in
        let v1 = map_ident v1 in
        let v2 = map_tok v2 in
        XmlSingleton (v0, v1, v2)
    | XmlFragment (v1, v2) ->
        let v1 = map_tok v1 in
        let v2 = map_tok v2 in
        XmlFragment (v1, v2)
  and map_xml_attribute = function
    | XmlAttr (v1, t, v2) ->
        let v1 = map_ident v1 and t = map_tok t and v2 = map_xml_attr v2 in
        XmlAttr (v1, t, v2)
    | XmlAttrExpr v ->
        let v = map_bracket map_expr v in
        XmlAttrExpr v
    | XmlEllipsis v -> let v = map_tok v in XmlEllipsis v

  and map_xml_attr v = map_expr v
  and map_xml_body =
    function
    | XmlText v1 -> let v1 = map_wrap map_of_string v1 in XmlText v1
    | XmlExpr v1 -> let v1 = map_bracket (map_of_option map_expr) v1 in
        XmlExpr v1
    | XmlXml v1 -> let v1 = map_xml v1 in XmlXml v1

  and map_name = function
    | Id (v1, v2) ->
        let v1 = map_ident v1 and v2 = map_id_info v2 in Id (v1, v2)
    | IdQualified (v1, v2) ->
        let v1 = map_name_ v1 and v2 = map_id_info v2 in IdQualified (v1, v2)

  and map_expr x =
    let k x = match x with
      | N v1 -> let v1 = map_name v1 in N v1
      | DotAccessEllipsis (v1, v2) -> let v1 = map_expr v1 in
          let v2 = map_tok v2 in
          DotAccessEllipsis (v1, v2)
      | DisjExpr (v1, v2) -> let v1 = map_expr v1 in let v2 = map_expr v2 in
          DisjExpr (v1, v2)
      | L v1 -> let v1 = map_literal v1 in L v1
      | Container (v1, v2) ->
          let v1 = map_container_operator v1
          and v2 = map_bracket (map_of_list map_expr) v2
          in Container (v1, v2)
      | Tuple v1 ->
          let v1 = map_bracket (map_of_list map_expr) v1 in Tuple v1
      | Record v1 ->
          let v1 = map_bracket (map_of_list map_field) v1 in
          Record v1
      | Constructor (v1, v2) ->
          let v1 = map_dotted_ident v1
          and v2 = map_of_list map_expr v2
          in Constructor (v1, v2)
      | Lambda v1 ->
          let v1 = map_function_definition v1 in Lambda v1
      | AnonClass v1 ->
          let v1 = map_class_definition v1 in AnonClass v1
      | Xml v1 -> let v1 = map_xml v1 in Xml v1
      | IdSpecial v1 -> let v1 = map_wrap map_special v1 in IdSpecial v1
      | Call (v1, v2) ->
          let v1 = map_expr v1 and v2 = map_arguments v2 in Call (v1, v2)
      | Assign (v1, v2, v3) ->
          let v1 = map_expr v1 and v2 = map_tok v2 and
        v3 = map_expr v3 in Assign (v1, v2, v3)
      | AssignOp (v1, v2, v3) ->
          let v1 = map_expr v1
          and v2 = map_wrap map_arithmetic_operator v2
          and v3 = map_expr v3
          in AssignOp (v1, v2, v3)
      | LetPattern (v1, v2) ->
          let v1 = map_pattern v1 and v2 = map_expr v2 in LetPattern (v1, v2)
      | DotAccess (v1, t, v2) ->
          let v1 = map_expr v1 and t = map_tok t and v2 = map_name_or_dynamic v2 in
          DotAccess (v1, t, v2)
      | ArrayAccess (v1, v2) ->
          let v1 = map_expr v1 and v2 = map_bracket map_expr v2 in
          ArrayAccess (v1, v2)
      | SliceAccess (v1, v2) ->
          let f = map_of_option map_expr in
          let v1 = map_expr v1
          and v2 = map_bracket (OCaml.map_of_all3 f f f) v2 in
          SliceAccess (v1, v2)
      | Conditional (v1, v2, v3) ->
          let v1 = map_expr v1
          and v2 = map_expr v2
          and v3 = map_expr v3
          in Conditional (v1, v2, v3)
      | TypedMetavar (v1, v2, v3) ->
          let v1 = map_ident v1
          and v2 = map_tok v2
          and v3 = map_type_ v3
          in TypedMetavar (v1, v2, v3)
      | MatchPattern (v1, v2) ->
          let v1 = map_expr v1
          and v2 = map_of_list map_action v2
          in MatchPattern (v1, v2)
      | Yield (t, v1, v2) ->
          let t = map_tok t in
          let v1 = map_of_option map_expr v1 and
            v2 = map_of_bool v2 in
          Yield (t, v1, v2)
      | Await (t, v1) ->
          let t = map_tok t in
          let v1 = map_expr v1 in Await (t, v1)
      | Cast (v1, v2) ->
          let v1 = map_type_ v1 and v2 = map_expr v2 in Cast (v1, v2)
      | Seq v1 ->
          let v1 = map_of_list map_expr v1 in Seq v1
      | Ref (t, v1) ->
          let t = map_tok t in
          let v1 = map_expr v1 in Ref (t, v1)
      | DeRef (t, v1) ->
          let t = map_tok t in
          let v1 = map_expr v1 in DeRef (t, v1)
      | Ellipsis v1 -> let v1 = map_tok v1 in Ellipsis v1
      | DeepEllipsis v1 -> let v1 = map_bracket map_expr v1 in DeepEllipsis v1
      | OtherExpr (v1, v2) ->
          let v1 = map_other_expr_operator v1
          and v2 = map_of_list map_any v2
          in OtherExpr (v1, v2)
    in
    vin.kexpr (k, all_functions) x

  and map_name_or_dynamic = function
    | EN v1 -> let v1 = map_name v1 in EN v1
    | EDynamic v1 -> let v1 = map_expr v1 in EDynamic v1

  and map_literal =
    function
    | Unit v1 -> let v1 = map_tok v1 in Unit v1
    | Bool v1 -> let v1 = map_wrap map_of_bool v1 in Bool v1
    | Int v1 -> let v1 = map_wrap map_id v1 in Int v1
    | Float v1 -> let v1 = map_wrap map_id v1 in Float v1
    | Imag v1 -> let v1 = map_wrap map_of_string v1 in Imag v1
    | Ratio v1 -> let v1 = map_wrap map_of_string v1 in Ratio v1
    | Atom v1 -> let v1 = map_wrap map_of_string v1 in Atom v1
    | Char v1 -> let v1 = map_wrap map_of_string v1 in Char v1
    | String v1 -> let v1 = map_wrap map_of_string v1 in String v1
    | Regexp v1 -> let v1 = map_wrap map_of_string v1 in Regexp v1
    | Null v1 -> let v1 = map_tok v1 in Null v1
    | Undefined v1 -> let v1 = map_tok v1 in Undefined v1

  and map_const_type =
    function
    | Cbool -> Cbool
    | Cint  -> Cint
    | Cstr  -> Cstr
    | Cany  -> Cany

  and map_constness =
    function
    | Lit v1 -> let v1 = map_literal v1 in Lit v1
    | Cst v1 -> let v1 = map_const_type v1 in Cst v1
    | NotCst -> NotCst

  and map_container_operator =
    function | Array -> Array | List -> List | Set -> Set | Dict -> Dict



  and map_special x =
    match x with
    | ForOf | Defined | This | Super | Self | Parent | Eval | Typeof | Instanceof
    | Sizeof | New | Spread | HashSplat | NextArrayIndex
      -> x
    | Op v1 -> let v1 = map_arithmetic_operator v1 in Op v1
    | EncodedString v1 -> let v1 = map_of_string v1 in EncodedString v1
    | IncrDecr (v1, v2) ->
        let v1 = map_of_incdec v1 and v2 = map_of_prepost v2 in IncrDecr (v1, v2)
    | ConcatString v1 -> let v1 = map_of_interpolated_kind v1 in
        ConcatString v1

  and map_of_interpolated_kind x = x
  and map_of_incdec x = x
  and map_of_prepost x = x
  and map_arithmetic_operator x = x

  and map_arguments v = map_bracket (map_of_list map_argument) v

  and map_argument =
    function
    | Arg v1 -> let v1 = map_expr v1 in Arg v1
    | ArgType v1 -> let v1 = map_type_ v1 in ArgType v1
    | ArgKwd (v1, v2) ->
        let v1 = map_ident v1 and v2 = map_expr v2 in ArgKwd (v1, v2)
    | ArgOther (v1, v2) ->
        let v1 = map_other_argument_operator v1
        and v2 = map_of_list map_any v2
        in ArgOther (v1, v2)

  and map_other_argument_operator x = x

  and map_action (v1, v2) =
    let v1 = map_pattern v1 and v2 = map_expr v2 in (v1, v2)

  and map_other_expr_operator x = x

  and map_type_ =
    function
    | TyEllipsis v1 -> let v1 = map_tok v1 in TyEllipsis v1
    | TyRecordAnon (v0, v1) ->
        let v0 = map_tok v0 in
        let v1 = map_bracket (map_of_list map_field) v1
        in TyRecordAnon (v0, v1)
    | TyInterfaceAnon (v0, v1) ->
        let v0 = map_tok v0 in
        let v1 = map_bracket (map_of_list map_field) v1
        in TyInterfaceAnon (v0, v1)
    | TyOr (v1, v2, v3) ->
        let v1 = map_type_ v1 in
        let v2 = map_tok v2 in
        let v3 = map_type_ v3 in
        TyOr (v1, v2, v3)
    | TyAnd (v1, v2, v3) ->
        let v1 = map_type_ v1 in
        let v2 = map_tok v2 in
        let v3 = map_type_ v3 in
        TyAnd (v1, v2, v3)
    | TyBuiltin v1 -> let v1 = map_wrap map_of_string v1 in TyBuiltin v1
    | TyFun (v1, v2) ->
        let v1 = map_of_list map_parameter v1
        and v2 = map_type_ v2
        in TyFun (v1, v2)
    | TyNameApply (v1, v2) ->
        let v1 = map_dotted_ident v1
        and v2 = map_type_arguments v2
        in TyNameApply (v1, v2)
    | TyN v1 -> let v1 = map_name v1 in TyN v1
    | TyVar v1 -> let v1 = map_ident v1 in TyVar v1
    | TyAny v1 -> let v1 = map_tok v1 in TyAny v1
    | TyArray (v1, v2) ->
        let v1 = map_bracket (map_of_option map_expr) v1
        and v2 = map_type_ v2
        in TyArray (v1, v2)
    | TyPointer (t, v1) ->
        let t = map_tok t in
        let v1 = map_type_ v1 in TyPointer (t, v1)
    | TyRef (t, v1) ->
        let t = map_tok t in
        let v1 = map_type_ v1 in TyRef (t, v1)
    | TyTuple v1 ->
        let v1 = map_bracket (map_of_list map_type_) v1 in
        TyTuple v1
    | TyQuestion (v1, t) ->
        let t = map_tok t in
        let v1 = map_type_ v1 in
        TyQuestion (v1, t)
    | TyRest (t, v1) ->
        let v1 = map_type_ v1 in
        let t = map_tok t in
        TyRest (t, v1)
    | OtherType (v1, v2) ->
        let v1 = map_other_type_operator v1
        and v2 = map_of_list map_any v2
        in OtherType (v1, v2)

  and map_type_arguments v = map_of_list map_type_argument v

  and map_type_argument =
    function
    | TypeArg v1 -> let v1 = map_type_ v1 in TypeArg v1
    | TypeWildcard (v1, v2) ->
        let v1 = map_tok v1 in
        let v2 =
          map_of_option (fun (v1, v2) -> map_wrap map_of_bool v1, map_type_ v2) v2
        in
        TypeWildcard (v1, v2)
    | TypeLifetime v1 -> let v1 = map_ident v1 in TypeLifetime v1
    | OtherTypeArg (v1, v2) ->
        let v1 = map_other_type_argument_operator v1 in
        let v2 = map_of_list map_any v2
        in OtherTypeArg (v1, v2)

  and map_other_type_operator x = x

  and map_other_type_argument_operator x = x

  and map_attribute = function
    | KeywordAttr v1 -> let v1 = map_wrap map_keyword_attribute v1 in
        KeywordAttr v1
    | NamedAttr (t, v1, v3) ->
        let t = map_tok t in
        let v1 = map_name v1
        and v3 = map_bracket (map_of_list map_argument) v3
        in NamedAttr (t, v1, v3)
    | OtherAttribute (v1, v2) ->
        let v1 = map_other_attribute_operator v1
        and v2 = map_of_list map_any v2
        in OtherAttribute (v1, v2)

  and map_keyword_attribute x = x
  and map_other_attribute_operator x  = x

  and map_stmt x =
    let k x =
      let skind =
        match x.s with
        | DisjStmt (v1, v2) -> let v1 = map_stmt v1 in let v2 = map_stmt v2 in
            DisjStmt (v1, v2)
        | ExprStmt (v1, t) ->
            let v1 = map_expr v1 in
            let t = map_tok t in
            ExprStmt (v1, t)
        | DefStmt v1 -> let v1 = map_definition v1 in DefStmt v1
        | DirectiveStmt v1 -> let v1 = map_directive v1 in DirectiveStmt v1
        | Block v1 -> let v1 = map_bracket (map_of_list map_stmt) v1 in Block v1
        | If (t, v1, v2, v3) ->
            let t = map_tok t in
            let v1 = map_expr v1
            and v2 = map_stmt v2
            and v3 = map_of_option map_stmt v3
            in If (t, v1, v2, v3)
        | While (t, v1, v2) ->
            let t = map_tok t in
            let v1 = map_expr v1 and v2 = map_stmt v2 in While (t, v1, v2)
        | DoWhile (t, v1, v2) ->
            let t = map_tok t in
            let v1 = map_stmt v1 and v2 = map_expr v2 in DoWhile (t, v1, v2)
        | For (t, v1, v2) ->
            let t = map_tok t in
            let v1 = map_for_header v1 and v2 = map_stmt v2 in For (t, v1, v2)
        | Switch (v0, v1, v2) ->
            let v0 = map_tok v0 in
            let v1 = map_of_option map_expr v1
            and v2 = map_of_list map_case_and_body v2
            in Switch (v0, v1, v2)
        | Return (t, v1, sc) ->
            let t = map_tok t in
            let v1 = map_of_option map_expr v1 in
            let sc = map_tok sc in
            Return (t, v1, sc)
        | Continue (t, v1, sc) ->
            let t = map_tok t in
            let v1 = map_label_ident v1 in
            let sc = map_tok sc in
            Continue (t, v1, sc)
        | Break (t, v1, sc) ->
            let t = map_tok t in
            let v1 = map_label_ident v1 in
            let sc = map_tok sc in
            Break (t, v1, sc)
        | Label (v1, v2) ->
            let v1 = map_label v1 and v2 = map_stmt v2 in Label (v1, v2)
        | Goto (t, v1) ->
            let t = map_tok t in
            let v1 = map_label v1 in Goto (t, v1)
        | Throw (t, v1, sc) ->
            let t = map_tok t in
            let v1 = map_expr v1 in
            let sc = map_tok sc in
            Throw (t, v1, sc)
        | Try (t, v1, v2, v3) ->
            let t = map_tok t in
            let v1 = map_stmt v1
            and v2 = map_of_list map_catch v2
            and v3 = map_of_option map_finally v3
            in Try (t, v1, v2, v3)
        | WithUsingResource (t, v1, v2) ->
            let t = map_tok t in
            let v1 = map_stmt v1 in
            let v2 = map_stmt v2 in
            WithUsingResource ((t, v1, v2))
        | Assert (t, v1, v2, sc) ->
            let t = map_tok t in
            let v1 = map_expr v1 in
            let v2 = map_of_option map_expr v2 in
            let sc = map_tok sc in
            Assert (t, v1, v2, sc)
        | OtherStmtWithStmt (v1, v2, v3) ->
            let v1 = map_other_stmt_with_stmt_operator v1
            and v2 = map_of_option map_expr v2
            and v3 = map_stmt v3
            in OtherStmtWithStmt (v1, v2, v3)
        | OtherStmt (v1, v2) ->
            let v1 = map_other_stmt_operator v1
            and v2 = map_of_list map_any v2
            in OtherStmt (v1, v2)
      in
      { x with s = skind }
    in
    vin.kstmt (k, all_functions) x

  and map_other_stmt_with_stmt_operator x = x

  and map_label_ident =
    function
    | LNone -> LNone
    | LId v1 -> let v1 = map_label v1 in LId v1
    | LInt v1 -> let v1 = map_wrap map_of_int v1 in LInt v1
    | LDynamic v1 -> let v1 = map_expr v1 in LDynamic v1

  and map_case_and_body = function
    | CasesAndBody (v1, v2) ->
        let v1 = map_of_list map_case v1 and v2 = map_stmt v2 in
        CasesAndBody (v1, v2)
    | CaseEllipsis v1 ->
        let v1 = map_tok v1 in
        CaseEllipsis v1

  and map_case =
    function
    | Case (t, v1) ->
        let t = map_tok t in
        let v1 = map_pattern v1 in Case (t, v1)
    | CaseEqualExpr (t, v1) ->
        let t = map_tok t in
        let v1 = map_expr v1 in CaseEqualExpr (t, v1)
    | Default t ->
        let t = map_tok t in
        Default t

  and map_catch (t, v1, v2) =
    let t = map_tok t in
    let v1 = map_pattern v1 and v2 = map_stmt v2 in (t, v1, v2)

  and map_finally v = map_tok_and_stmt v

  and map_tok_and_stmt (t, v) =
    let t = map_tok t in
    let v = map_stmt v in
    (t, v)

  and map_label v = map_ident v

  and map_for_header =
    function
    | ForClassic (v1, v2, v3) ->
        let v1 = map_of_list map_for_var_or_expr v1
        and v2 = map_of_option map_expr v2
        and v3 = map_of_option map_expr v3
        in ForClassic (v1, v2, v3)
    | ForEach (v1, t, v2) ->
        let t = map_tok t in
        let v1 = map_pattern v1 and v2 = map_expr v2 in ForEach (v1, t, v2)
    | ForEllipsis t -> let t = map_tok t in ForEllipsis t
    | ForIn (v1, v2) ->
        let v1 = map_of_list map_for_var_or_expr v1
        and v2 = map_of_list map_expr v2
        in ForIn (v1, v2)

  and map_for_var_or_expr =
    function
    | ForInitVar (v1, v2) ->
        let v1 = map_entity v1
        and v2 = map_variable_definition v2
        in ForInitVar (v1, v2)
    | ForInitExpr v1 -> let v1 = map_expr v1 in ForInitExpr v1

  and map_other_stmt_operator x = x

  and map_pattern =
    function
    | PatEllipsis v1 -> let v1 = map_tok v1 in PatEllipsis v1
    | PatRecord v1 ->
        let v1 =
          map_bracket (map_of_list
                         (fun (v1, v2) ->
                            let v1 = map_dotted_ident v1 and v2 = map_pattern v2 in (v1, v2)))
            v1
        in PatRecord v1
    | PatId (v1, v2) ->
        let v1 = map_ident v1 and v2 = map_id_info v2 in PatId (v1, v2)
    | PatVar (v1, v2) ->
        let v1 = map_type_ v1
        and v2 =
          map_of_option
            (fun (v1, v2) ->
               let v1 = map_ident v1 and v2 = map_id_info v2 in (v1, v2))
            v2
        in PatVar (v1, v2)
    | PatLiteral v1 -> let v1 = map_literal v1 in PatLiteral v1
    | PatType v1 -> let v1 = map_type_ v1 in PatType v1
    | PatConstructor (v1, v2) ->
        let v1 = map_dotted_ident v1
        and v2 = map_of_list map_pattern v2
        in PatConstructor (v1, v2)
    | PatTuple v1 -> let v1 = map_bracket (map_of_list map_pattern) v1 in PatTuple v1
    | PatList v1 -> let v1 = map_bracket (map_of_list map_pattern) v1 in
        PatList v1
    | PatKeyVal (v1, v2) ->
        let v1 = map_pattern v1 and v2 = map_pattern v2 in PatKeyVal (v1, v2)
    | PatUnderscore v1 -> let v1 = map_tok v1 in PatUnderscore v1
    | PatDisj (v1, v2) ->
        let v1 = map_pattern v1 and v2 = map_pattern v2 in PatDisj (v1, v2)
    | DisjPat (v1, v2) ->
        let v1 = map_pattern v1 and v2 = map_pattern v2 in DisjPat (v1, v2)
    | PatTyped (v1, v2) ->
        let v1 = map_pattern v1 and v2 = map_type_ v2 in PatTyped (v1, v2)
    | PatAs (v1, v2) ->
        let v1 = map_pattern v1
        and v2 =
          (match v2 with
           | (v1, v2) ->
               let v1 = map_ident v1 and v2 = map_id_info v2 in (v1, v2))
        in PatAs (v1, v2)
    | PatWhen (v1, v2) ->
        let v1 = map_pattern v1 and v2 = map_expr v2 in PatWhen (v1, v2)
    | OtherPat (v1, v2) ->
        let v1 = map_other_pattern_operator v1
        and v2 = map_of_list map_any v2
        in OtherPat (v1, v2)

  and map_other_pattern_operator x = x

  and map_definition (v1, v2) =

    let v1 = map_entity v1 and v2 = map_definition_kind v2 in (v1, v2)

  and
    map_entity {
      name = v_name;
      attrs = v_attrs;
      tparams = v_tparams;
    } =
    let v_tparams = map_of_list map_type_parameter v_tparams in
    let v_attrs = map_of_list map_attribute v_attrs in
    let v_name = map_name_or_dynamic v_name
    in {
      name = v_name;
      attrs = v_attrs;
      tparams = v_tparams;
    }
  and map_definition_kind =
    function
    | FuncDef v1 -> let v1 = map_function_definition v1 in FuncDef v1
    | VarDef v1 -> let v1 = map_variable_definition v1 in VarDef v1
    | FieldDefColon v1 -> let v1 = map_variable_definition v1 in FieldDefColon v1
    | ClassDef v1 -> let v1 = map_class_definition v1 in ClassDef v1
    | TypeDef v1 -> let v1 = map_type_definition v1 in TypeDef v1
    | ModuleDef v1 -> let v1 = map_module_definition v1 in ModuleDef v1
    | MacroDef v1 -> let v1 = map_macro_definition v1 in MacroDef v1
    | Signature v1 -> let v1 = map_type_ v1 in Signature v1
    | UseOuterDecl v1 -> let v1 = map_tok v1 in UseOuterDecl v1
    | OtherDef (v1, v2) ->
        let v1 = map_other_def_operator v1 in
        let v2 = map_of_list map_any v2 in
        OtherDef (v1, v2)

  and map_other_def_operator x = x

  and map_module_definition { mbody = v_mbody } =
    let v_mbody = map_module_definition_kind v_mbody in
    { mbody = v_mbody; }
  and map_module_definition_kind =
    function
    | ModuleAlias v1 -> let v1 = map_dotted_ident v1 in ModuleAlias v1
    | ModuleStruct (v1, v2) ->
        let v1 = map_of_option map_dotted_ident v1
        and v2 = map_of_list map_item v2
        in ModuleStruct (v1, v2)
    | OtherModule (v1, v2) ->
        let v1 = map_other_module_operator v1
        and v2 = map_of_list map_any v2
        in OtherModule (v1, v2)
  and map_other_module_operator x = x
  and
    map_macro_definition { macroparams = v_macroparams; macrobody = v_macrobody
                         } =
    let v_macrobody = map_of_list map_any v_macrobody in
    let v_macroparams = map_of_list map_ident v_macroparams in
    { macroparams = v_macroparams; macrobody = v_macrobody }

  and map_type_parameter (v1, v2) =
    let v1 = map_ident v1 and v2 = map_type_parameter_constraints v2 in (v1, v2)

  and map_type_parameter_constraints v =
    map_of_list map_type_parameter_constraint v

  and map_type_parameter_constraint =
    function | Extends v1 -> let v1 = map_type_ v1 in Extends v1
             | HasConstructor t -> let t = map_tok t in HasConstructor t
             | OtherTypeParam (t, xs) ->
                 let t = map_other_type_parameter_operator t in
                 let xs = map_of_list map_any xs
                 in OtherTypeParam (t, xs)

  and map_other_type_parameter_operator x = x

  and map_function_kind x = x

  and
    map_function_definition {
      fkind;
      fparams = v_fparams;
      frettype = v_frettype;
      fbody = v_fbody
    } =
    let fkind = map_wrap map_function_kind fkind in
    let v_fbody = map_stmt v_fbody in
    let v_frettype = map_of_option map_type_ v_frettype in
    let v_fparams = map_parameters v_fparams in
    {
      fkind;
      fparams = v_fparams;
      frettype = v_frettype;
      fbody = v_fbody
    }

  and map_parameters v = map_of_list map_parameter v

  and map_parameter =
    function
    | ParamClassic v1 ->
        let v1 = map_parameter_classic v1 in ParamClassic v1
    | ParamRest (v0, v1) ->
        let v0 = map_tok v0 in
        let v1 = map_parameter_classic v1 in ParamRest (v0, v1)
    | ParamHashSplat (v0, v1) ->
        let v0 = map_tok v0 in
        let v1 = map_parameter_classic v1 in ParamHashSplat (v0, v1)
    | ParamPattern v1 -> let v1 = map_pattern v1 in ParamPattern v1
    | ParamEllipsis v1 -> let v1 = map_tok v1 in ParamEllipsis v1
    | OtherParam (v1, v2) ->
        let v1 = map_other_parameter_operator v1
        and v2 = map_of_list map_any v2
        in OtherParam (v1, v2)

  and
    map_parameter_classic {
      pname = v_pname;
      pdefault = v_pdefault;
      ptype = v_ptype;
      pattrs = v_pattrs;
      pinfo = v_pinfo;
    } =
    let v_pinfo = map_id_info v_pinfo in
    let v_pattrs = map_of_list map_attribute v_pattrs in
    let v_ptype = map_of_option map_type_ v_ptype in
    let v_pdefault = map_of_option map_expr v_pdefault in
    let v_pname = map_of_option map_ident v_pname in
    {
      pname = v_pname;
      pdefault = v_pdefault;
      ptype = v_ptype;
      pattrs = v_pattrs;
      pinfo = v_pinfo;
    }

  and map_other_parameter_operator x = x

  and map_variable_definition { vinit = v_vinit; vtype = v_vtype } =
    let v_vtype = map_of_option map_type_ v_vtype in
    let v_vinit = map_of_option map_expr v_vinit in
    { vinit = v_vinit; vtype = v_vtype }

  and map_field =
    function
    | FieldSpread (t, v1) ->
        let t = map_tok t in
        let v1 = map_expr v1 in FieldSpread (t, v1)
    | FieldStmt v1 -> let v1 = map_stmt v1 in FieldStmt v1

  and map_type_definition { tbody = v_tbody } =
    let v_tbody = map_type_definition_kind v_tbody in {
      tbody = v_tbody
    }
  and map_type_definition_kind =
    function
    | OrType v1 ->
        let v1 = map_of_list map_or_type_element v1 in OrType v1
    | AndType v1 -> let v1 = map_bracket (map_of_list map_field) v1 in
        AndType v1
    | AliasType v1 -> let v1 = map_type_ v1 in AliasType v1
    | NewType v1 -> let v1 = map_type_ v1 in NewType v1
    | Exception (v1, v2) ->
        let v1 = map_ident v1
        and v2 = map_of_list map_type_ v2
        in Exception (v1, v2)
    | OtherTypeKind (v1, v2) ->
        let v1 = map_other_type_kind_operator v1
        and v2 = map_of_list map_any v2
        in OtherTypeKind (v1, v2)

  and map_other_type_kind_operator x = x

  and map_or_type_element =
    function
    | OrConstructor (v1, v2) ->
        let v1 = map_ident v1
        and v2 = map_of_list map_type_ v2
        in OrConstructor (v1, v2)
    | OrEnum (v1, v2) ->
        let v1 = map_ident v1 and v2 = map_of_option map_expr v2 in OrEnum (v1, v2)
    | OrUnion (v1, v2) ->
        let v1 = map_ident v1 and v2 = map_type_ v2 in OrUnion (v1, v2)
    | OtherOr (v1, v2) ->
        let v1 = map_other_or_type_element_operator v1
        and v2 = map_of_list map_any v2
        in OtherOr (v1, v2)
  and map_other_or_type_element_operator x = x

  and
    map_class_definition {
      ckind = v_ckind;
      cextends = v_cextends;
      cimplements = v_cimplements;
      cbody = v_cbody;
      cmixins = v_cmixins;
    } =
    let v_cbody = map_bracket (map_of_list map_field) v_cbody in
    let v_cmixins = map_of_list map_type_ v_cmixins in
    let v_cimplements = map_of_list map_type_ v_cimplements in
    let v_cextends = map_of_list map_type_ v_cextends in
    let v_ckind = map_class_kind v_ckind in
    {
      ckind = v_ckind;
      cextends = v_cextends;
      cimplements = v_cimplements;
      cbody = v_cbody;
      cmixins = v_cmixins;
    }

  and map_class_kind (x,t) =
    x, map_tok t

  and map_directive =
    function
    | ImportFrom (t, v1, v2, v3) ->
        let t = map_tok t in
        let v1 = map_module_name v1
        and v2, v3 = map_alias (v2, v3)
        in ImportFrom (t, v1, v2, v3)
    | ImportAs (t, v1, v2) ->
        let t = map_tok t in
        let v1 = map_module_name v1
        and v2 = map_of_option map_ident_and_id_info v2
        in ImportAs (t, v1, v2)
    | ImportAll (t, v1, v2) ->
        let t = map_tok t in
        let v1 = map_module_name v1
        and v2 = map_tok v2
        in ImportAll (t, v1, v2)
    | OtherDirective (v1, v2) ->
        let v1 = map_other_directive_operator v1
        and v2 = map_of_list map_any v2
        in OtherDirective (v1, v2)
    | Pragma (v1, v2) ->
        let v1 = map_ident v1
        and v2 = map_of_list map_any v2
        in Pragma (v1, v2)
    | Package (t, v1) ->
        let t = map_tok t in
        let v1 = map_dotted_ident v1
        in Package (t, v1)
    | PackageEnd t ->
        let t = map_tok t in
        PackageEnd t

  and map_ident_and_id_info (v1, v2) =
    let v1 = map_ident v1 in
    let v2 = map_id_info v2 in
    (v1, v2)

  and map_alias (v1, v2) =
    let v1 = map_ident v1 and v2 = map_of_option map_ident_and_id_info v2 in (v1, v2)

  and map_other_directive_operator x = x

  and map_item x = map_stmt x

  and map_program v = map_of_list map_item v

  and map_partial = function
    | PartialDef v1 -> let v1 = map_definition v1 in PartialDef v1
    | PartialIf (v1, v2) ->
        let v1 = map_tok v1 in
        let v2 = map_expr v2 in
        PartialIf (v1, v2)
    | PartialTry (v1, v2) ->
        let v1 = map_tok v1 in
        let v2 = map_stmt v2 in
        PartialTry (v1, v2)
    | PartialFinally (v1, v2) ->
        let v1 = map_tok v1 in
        let v2 = map_stmt v2 in
        PartialFinally (v1, v2)
    | PartialCatch (v1) ->
        let v1 = map_catch v1 in
        PartialCatch (v1)
    | PartialSingleField (v1, v2, v3) ->
        let v1 = map_wrap map_of_string v1 in
        let v2 = map_tok v2 in
        let v3 = map_expr v3 in
        PartialSingleField (v1, v2, v3)

  and map_any =
    function
    | Str v1 -> let v1 = map_wrap map_of_string v1 in Str v1
    | Args v1 -> let v1 = map_of_list map_argument v1 in Args v1
    | Partial v1 -> let v1 = map_partial v1 in Partial v1
    | TodoK v1 -> let v1 = map_ident v1 in TodoK v1
    | Tk v1 -> let v1 = map_tok v1 in Tk v1
    | I v1 -> let v1 = map_ident v1 in I v1
    | Modn v1 -> let v1 = map_module_name v1 in Modn v1
    | ModDk v1 -> let v1 = map_module_definition_kind v1 in ModDk v1
    | En v1 -> let v1 = map_entity v1 in En v1
    | E v1 -> let v1 = map_expr v1 in E v1
    | S v1 -> let v1 = map_stmt v1 in S v1
    | Ss v1 -> let v1 = map_of_list map_stmt v1 in Ss v1
    | T v1 -> let v1 = map_type_ v1 in T v1
    | P v1 -> let v1 = map_pattern v1 in P v1
    | Def v1 -> let v1 = map_definition v1 in Def v1
    | Dir v1 -> let v1 = map_directive v1 in Dir v1
    | Fld v1 -> let v1 = map_field v1 in Fld v1
    | Di v1 -> let v1 = map_dotted_ident v1 in Di v1
    | Pa v1 -> let v1 = map_parameter v1 in Pa v1
    | Ar v1 -> let v1 = map_argument v1 in Ar v1
    | At v1 -> let v1 = map_attribute v1 in At v1
    | Dk v1 -> let v1 = map_definition_kind v1 in Dk v1
    | Pr v1 -> let v1 = map_program v1 in Pr v1
    | Lbli v1 -> let v1 = map_label_ident v1 in Lbli v1
    | NoD v1 -> let v1 = map_name_or_dynamic v1 in NoD v1

  and all_functions =
    {
      vitem = map_item;
      vprogram = map_program;
      vexpr = map_expr;
      vany = map_any;
    }
  in
  all_functions
