(* Note that ii_of_any relies on Visitor_AST which itself
 * uses OCaml.v_ref_do_not_visit, so no need to worry about
 * tokens inside id_type or id_info.
 *)
val ii_of_any : AST_generic.any -> Tok.t list
val info_of_any : AST_generic.any -> Tok.t

(* may raise NoTokenLocation *)
val first_info_of_any : AST_generic.any -> Tok.t
val range_of_tokens : Tok.t list -> Tok_range.t
val range_of_any_opt : AST_generic.any -> (Tok.location * Tok.location) option

(* poor's man fold *)
(*
val do_visit_with_ref:
  ('a list ref -> visitor_in) -> any -> 'a list
*)
