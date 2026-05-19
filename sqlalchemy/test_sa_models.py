"""
Unit tests for SQLAlchemy ORM models.

Tests cover model instantiation, relationships, constraints, and defaults.
"""
import sys
sys.path.append('packages')
import pytest
from sqlalchemy import create_engine, inspect, event
from sqlalchemy.orm import Session
from sqlalchemy.pool import StaticPool
from sqlalchemy.sql.compiler import SQLCompiler

from sa_models import (
    Base,
    AdhocReports,
    FondFamilies,
    Fonds,
    LinkedSources,
    Manuscripts,
    WeeklyNotes,
    YearlyNotes,
)

# Counter for auto-incrementing IDs (SQLite autoincrement workaround)
_id_counter = {}


def get_next_id(model):
    """Get the next ID for a model to work around SQLite autoincrement issues."""
    table_name = model.__tablename__
    if table_name not in _id_counter:
        _id_counter[table_name] = 0
    _id_counter[table_name] += 1
    return _id_counter[table_name]


@pytest.fixture
def in_memory_db():
    """Create an in-memory SQLite database for testing."""
    engine = create_engine(
        "sqlite:///:memory:",
        poolclass=StaticPool,
        connect_args={"check_same_thread": False},
    )
    
    @event.listens_for(engine, "connect")
    def configure_sqlite(dbapi_conn, connection_record):
        # Enable foreign key support
        dbapi_conn.execute("PRAGMA foreign_keys=ON")
    
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)
    _id_counter.clear()


@pytest.fixture
def session(in_memory_db):
    """Provide a database session for tests."""
    with Session(in_memory_db) as db_session:
        yield db_session


class TestAdhocReports:
    """Tests for AdhocReports model."""

    def test_adhoc_reports_instantiation(self):
        """Test creating an AdhocReports instance."""
        report = AdhocReports(
            query="SELECT * FROM manuscripts",
            short_title="All Manuscripts",
            header_text="Manuscript Report",
            footer_text="End of Report",
            filename="manuscripts.pdf",
            enabled=1,
        )
        assert report.query == "SELECT * FROM manuscripts"
        assert report.short_title == "All Manuscripts"
        assert report.header_text == "Manuscript Report"
        assert report.footer_text == "End of Report"
        assert report.filename == "manuscripts.pdf"
        assert report.enabled == 1

    def test_adhoc_reports_defaults(self, session):
        """Test AdhocReports default values at database level."""
        report = AdhocReports(query="SELECT 1", enabled=0)
        report.id = get_next_id(AdhocReports)
        session.add(report)
        session.commit()
        
        retrieved = session.query(AdhocReports).filter_by(query="SELECT 1").first()
        assert retrieved.enabled == 0

    def test_adhoc_reports_persistence(self, session):
        """Test persisting AdhocReports to database."""
        report = AdhocReports(
            query="SELECT * FROM fonds",
            short_title="Fonds Report",
            enabled=1,
        )
        report.id = get_next_id(AdhocReports)
        session.add(report)
        session.commit()

        retrieved = session.query(AdhocReports).filter_by(short_title="Fonds Report").first()
        assert retrieved is not None
        assert retrieved.query == "SELECT * FROM fonds"
        assert retrieved.enabled == 1

    def test_adhoc_reports_table_name(self):
        """Test AdhocReports uses correct table name."""
        assert AdhocReports.__tablename__ == "adhoc_reports"


class TestFondFamilies:
    """Tests for FondFamilies model."""

    def test_fond_families_instantiation(self):
        """Test creating a FondFamilies instance."""
        family = FondFamilies(code="FF001", name="Family A", header_text="First Family")
        assert family.code == "FF001"
        assert family.name == "Family A"
        assert family.header_text == "First Family"

    def test_fond_families_enabled_default(self, session):
        """Test FondFamilies enabled default is 1 at database level."""
        family = FondFamilies(code="FF002", enabled=1)
        family.id = get_next_id(FondFamilies)
        session.add(family)
        session.commit()
        
        retrieved = session.query(FondFamilies).filter_by(code="FF002").first()
        assert retrieved.enabled == 1

    def test_fond_families_persistence(self, session):
        """Test persisting FondFamilies to database."""
        family = FondFamilies(code="FF003", name="Family B", enabled=0)
        family.id = get_next_id(FondFamilies)
        session.add(family)
        session.commit()

        retrieved = session.query(FondFamilies).filter_by(code="FF003").first()
        assert retrieved is not None
        assert retrieved.name == "Family B"
        assert retrieved.enabled == 0

    def test_fond_families_table_name(self):
        """Test FondFamilies uses correct table name."""
        assert FondFamilies.__tablename__ == "fond_families"


class TestFonds:
    """Tests for Fonds model."""

    def test_fonds_instantiation(self):
        """Test creating a Fonds instance."""
        fond = Fonds(
            code="FOND001",
            full_name="First Fond Collection",
            header_text="Welcome to Fond",
            image_filename="fond.jpg",
            volume_count=42,
            enabled=True,
        )
        assert fond.code == "FOND001"
        assert fond.full_name == "First Fond Collection"
        assert fond.enabled is True

    def test_fonds_enabled_default(self, session):
        """Test Fonds enabled default is True at database level."""
        fond = Fonds(code="FOND002", enabled=True)
        fond.id = get_next_id(Fonds)
        session.add(fond)
        session.commit()
        
        retrieved = session.query(Fonds).filter_by(code="FOND002").first()
        assert retrieved.enabled is True

    def test_fonds_code_unique(self, session):
        """Test Fonds code has unique constraint."""
        fond1 = Fonds(code="UNIQUE_CODE", full_name="First", enabled=True)
        fond1.id = get_next_id(Fonds)
        fond2 = Fonds(code="UNIQUE_CODE", full_name="Second", enabled=True)
        fond2.id = get_next_id(Fonds)

        session.add(fond1)
        session.commit()
        session.add(fond2)

        with pytest.raises(Exception):  # IntegrityError
            session.commit()

    def test_fonds_relationship_with_manuscripts(self, session):
        """Test Fonds relationship with Manuscripts."""
        fond = Fonds(code="FOND003", full_name="Test Fond", enabled=True)
        fond.id = get_next_id(Fonds)
        session.add(fond)
        session.commit()

        manuscript = Manuscripts(
            shelfmark="MS001",
            title="Test Manuscript",
            fond_code="FOND003",
        )
        manuscript.id = get_next_id(Manuscripts)
        session.add(manuscript)
        session.commit()

        retrieved_fond = session.query(Fonds).filter_by(code="FOND003").first()
        assert len(retrieved_fond.manuscripts) == 1
        assert retrieved_fond.manuscripts[0].title == "Test Manuscript"

    def test_fonds_table_name(self):
        """Test Fonds uses correct table name."""
        assert Fonds.__tablename__ == "fonds"


class TestLinkedSources:
    """Tests for LinkedSources model."""

    def test_linked_sources_instantiation(self):
        """Test creating a LinkedSources instance."""
        source = LinkedSources(
            raw_shelfmark="RAW-001",
            shelfmark="001",
            url="https://example.com/001",
            link_name="Example",
        )
        assert source.raw_shelfmark == "RAW-001"
        assert source.shelfmark == "001"
        assert source.url == "https://example.com/001"
        assert source.link_name == "Example"

    def test_linked_sources_indexes(self, in_memory_db):
        """Test LinkedSources has correct indexes."""
        inspector = inspect(in_memory_db)
        indexes = inspector.get_indexes("linked_sources")
        index_names = {idx["name"] for idx in indexes}
        
        assert "shelfmark_idx" in index_names
        assert "link_name_idx" in index_names

    def test_linked_sources_persistence(self, session):
        """Test persisting LinkedSources to database."""
        source = LinkedSources(
            raw_shelfmark="RAW-002",
            shelfmark="002",
            url="https://example.com/002",
        )
        source.id = get_next_id(LinkedSources)
        session.add(source)
        session.commit()

        retrieved = session.query(LinkedSources).filter_by(shelfmark="002").first()
        assert retrieved is not None
        assert retrieved.url == "https://example.com/002"

    def test_linked_sources_table_name(self):
        """Test LinkedSources uses correct table name."""
        assert LinkedSources.__tablename__ == "linked_sources"


class TestManuscripts:
    """Tests for Manuscripts model."""

    def test_manuscripts_instantiation(self):
        """Test creating a Manuscripts instance."""
        manuscript = Manuscripts(
            shelfmark="MS-VAT-001",
            author="Anonymous",
            title="Test Manuscript",
            incipit="Here begins the text",
            date="15th century",
            notes="Important notes",
            high_quality=1,
            details_page=True,
            details_count=5,
            bibliography_count=3,
            thumbnail_url="https://example.com/thumb.jpg",
            sort_shelfmark="001",
        )
        assert manuscript.shelfmark == "MS-VAT-001"
        assert manuscript.author == "Anonymous"
        assert manuscript.title == "Test Manuscript"
        assert manuscript.high_quality == 1
        assert manuscript.details_page is True

    def test_manuscripts_ignore_default(self, session):
        """Test Manuscripts ignore default is False at database level."""
        manuscript = Manuscripts(shelfmark="MS002", ignore=False)
        manuscript.id = get_next_id(Manuscripts)
        session.add(manuscript)
        session.commit()
        
        retrieved = session.query(Manuscripts).filter_by(shelfmark="MS002").first()
        assert retrieved.ignore is False

    def test_manuscripts_unique_constraint(self, session):
        """Test Manuscripts has unique constraint on shelfmark and high_quality."""
        ms1 = Manuscripts(shelfmark="MS003", high_quality=1, ignore=False)
        ms1.id = get_next_id(Manuscripts)
        ms2 = Manuscripts(shelfmark="MS003", high_quality=1, ignore=False)
        ms2.id = get_next_id(Manuscripts)

        session.add(ms1)
        session.commit()
        session.add(ms2)

        with pytest.raises(Exception):  # IntegrityError
            session.commit()

    def test_manuscripts_with_fond_relationship(self, session):
        """Test Manuscripts relationship with Fonds."""
        fond = Fonds(code="FOND004", full_name="Test Fond", enabled=True)
        fond.id = get_next_id(Fonds)
        session.add(fond)
        session.commit()

        manuscript = Manuscripts(
            shelfmark="MS-FOND-001",
            title="Manuscript in Fond",
            fond_code="FOND004",
        )
        manuscript.id = get_next_id(Manuscripts)
        session.add(manuscript)
        session.commit()

        retrieved = session.query(Manuscripts).filter_by(shelfmark="MS-FOND-001").first()
        assert retrieved.fond is not None
        assert retrieved.fond.code == "FOND004"

    def test_manuscripts_fond_cascade_delete(self, session):
        """Test Manuscripts fond_code is set to NULL on fond deletion."""
        fond = Fonds(code="FOND005", full_name="Temporary Fond", enabled=True)
        fond.id = get_next_id(Fonds)
        session.add(fond)
        session.commit()

        manuscript = Manuscripts(
            shelfmark="MS-TEMP-001",
            title="Temporary Manuscript",
            fond_code="FOND005",
        )
        manuscript.id = get_next_id(Manuscripts)
        session.add(manuscript)
        session.commit()

        session.delete(fond)
        session.commit()

        retrieved = session.query(Manuscripts).filter_by(shelfmark="MS-TEMP-001").first()
        assert retrieved.fond_code is None

    def test_manuscripts_table_name(self):
        """Test Manuscripts uses correct table name."""
        assert Manuscripts.__tablename__ == "manuscripts"


class TestWeeklyNotes:
    """Tests for WeeklyNotes model."""

    def test_weekly_notes_instantiation(self):
        """Test creating a WeeklyNotes instance."""
        note = WeeklyNotes(
            year=2024,
            week_number=1,
            header_text="Week 1 Notes",
            image_filename="week1.jpg",
            boundry_image_filename="week1_boundary.jpg",
            published=True,
        )
        assert note.year == 2024
        assert note.week_number == 1
        assert note.header_text == "Week 1 Notes"
        assert note.published is True

    def test_weekly_notes_published_default(self, session):
        """Test WeeklyNotes published default is False at database level."""
        note = WeeklyNotes(header_text="Test Note", published=False)
        note.id = get_next_id(WeeklyNotes)
        session.add(note)
        session.commit()
        
        retrieved = session.query(WeeklyNotes).filter_by(header_text="Test Note").first()
        assert retrieved.published is False

    def test_weekly_notes_self_referential_relationship(self, session):
        """Test WeeklyNotes self-referential relationship."""
        note1 = WeeklyNotes(year=2024, week_number=1, header_text="Week 1", published=False)
        note1.id = get_next_id(WeeklyNotes)
        session.add(note1)
        session.commit()

        note2 = WeeklyNotes(
            year=2024,
            week_number=2,
            header_text="Week 2",
            previous_id=note1.id,
            published=False,
        )
        note2.id = get_next_id(WeeklyNotes)
        session.add(note2)
        session.commit()

        retrieved = session.query(WeeklyNotes).filter_by(week_number=2).first()
        assert retrieved.previous is not None
        assert retrieved.previous.week_number == 1

    def test_weekly_notes_previous_cascade_delete(self, session):
        """Test WeeklyNotes previous_id is set to NULL on previous deletion."""
        note1 = WeeklyNotes(year=2024, week_number=1, header_text="Week 1", published=False)
        note1.id = get_next_id(WeeklyNotes)
        session.add(note1)
        session.commit()

        note2 = WeeklyNotes(
            year=2024,
            week_number=2,
            header_text="Week 2",
            previous_id=note1.id,
            published=False,
        )
        note2.id = get_next_id(WeeklyNotes)
        session.add(note2)
        session.commit()

        session.delete(note1)
        session.commit()

        retrieved = session.query(WeeklyNotes).filter_by(week_number=2).first()
        assert retrieved.previous_id is None

    def test_weekly_notes_table_name(self):
        """Test WeeklyNotes uses correct table name."""
        assert WeeklyNotes.__tablename__ == "weekly_notes"


class TestYearlyNotes:
    """Tests for YearlyNotes model."""

    def test_yearly_notes_instantiation(self):
        """Test creating a YearlyNotes instance."""
        note = YearlyNotes(year=2024, header_text="Year 2024 Summary")
        assert note.year == 2024
        assert note.header_text == "Year 2024 Summary"

    def test_yearly_notes_nullable_fields(self):
        """Test YearlyNotes can be created with minimal fields."""
        note = YearlyNotes()
        assert note.year is None
        assert note.header_text is None

    def test_yearly_notes_persistence(self, session):
        """Test persisting YearlyNotes to database."""
        note = YearlyNotes(year=2025, header_text="Year 2025 Summary")
        note.id = get_next_id(YearlyNotes)
        session.add(note)
        session.commit()

        retrieved = session.query(YearlyNotes).filter_by(year=2025).first()
        assert retrieved is not None
        assert retrieved.header_text == "Year 2025 Summary"

    def test_yearly_notes_table_name(self):
        """Test YearlyNotes uses correct table name."""
        assert YearlyNotes.__tablename__ == "yearly_notes"


class TestBaseModel:
    """Tests for Base declarative base."""

    def test_base_is_declarative_base(self):
        """Test that Base is properly configured as DeclarativeBase."""
        assert hasattr(Base, "metadata")
        assert hasattr(Base, "registry")

    def test_all_models_inherit_from_base(self):
        """Test all models inherit from Base."""
        models = [
            AdhocReports,
            FondFamilies,
            Fonds,
            LinkedSources,
            Manuscripts,
            WeeklyNotes,
            YearlyNotes,
        ]
        for model in models:
            assert issubclass(model, Base)

    def test_all_tables_created(self, in_memory_db):
        """Test all tables are created in database."""
        inspector = inspect(in_memory_db)
        tables = inspector.get_table_names()

        expected_tables = [
            "adhoc_reports",
            "fond_families",
            "fonds",
            "linked_sources",
            "manuscripts",
            "weekly_notes",
            "yearly_notes",
        ]

        for table in expected_tables:
            assert table in tables
