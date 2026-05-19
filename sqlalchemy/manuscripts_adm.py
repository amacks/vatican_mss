from fastapi import FastAPI
from sqladmin import Admin, ModelView
from sqladmin.filters import BooleanFilter, AllUniqueStringValuesFilter, ForeignKeyFilter, OperationColumnFilter
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from sa_models import Base, Manuscripts, Fonds


engine = create_engine("mysql+pymysql://vatican_ro:hiHedEnn@127.0.0.1/vatican_mss")

app = FastAPI()
admin = Admin(app, engine)


class ManuscriptsAdmin(ModelView, model=Manuscripts):
    name = "Manuscript"
    column_list = [Manuscripts.id, Manuscripts.shelfmark, Manuscripts.author, Manuscripts.title, Manuscripts.incipit, Manuscripts.date, Manuscripts.notes, Manuscripts.fond_code, Manuscripts.sort_shelfmark]
    can_create = False
    can_edit = True
    can_delete = False
    can_view_details = True
    column_searchable_list = [Manuscripts.sort_shelfmark, Manuscripts.author, Manuscripts.title]
    column_default_sort = (Manuscripts.id, True)  # Sort by id in descending order
    column_filterable_list = [Manuscripts.fond_code]
    column_filters = [
        ForeignKeyFilter(Manuscripts.fond_code, Fonds.code)
    ]
    column_details_list = [Manuscripts.id, Manuscripts.shelfmark, Manuscripts.author, Manuscripts.title, Manuscripts.incipit, Manuscripts.date, Manuscripts.notes, Manuscripts.fond_code, Manuscripts.sort_shelfmark]
    column_formatters = {
        "fond_code": lambda obj, _: obj.fond_code
    }


class FondsAdmin(ModelView, model=Fonds):
    name = "Fond"
    column_list = [Fonds.id, Fonds.code, Fonds.full_name, Fonds.header_text, Fonds.image_filename, Fonds.volume_count, Fonds.enabled]
    can_create = False
    can_edit = True
    can_delete = False
    can_view_details = True
    column_searchable_list = [Fonds.code, Fonds.full_name]
    column_default_sort = (Fonds.code, False)  # Sort by id in descending order
    column_details_list = [Fonds.id, Fonds.code, Fonds.full_name, Fonds.header_text, Fonds.image_filename, Fonds.volume_count, Fonds.enabled]

admin.add_view(ManuscriptsAdmin)
admin.add_view(FondsAdmin)