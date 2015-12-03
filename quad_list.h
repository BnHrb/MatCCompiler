struct quad_list* quad_list_new(struct quad*);
void              quad_list_free(struct quad_list*);
void              quad_list_add(struct quad_list**,struct quad_list*);
void              quad_list_complete(struct quad_list*, struct symbol*);
void              quad_list_print(struct quad_list*);