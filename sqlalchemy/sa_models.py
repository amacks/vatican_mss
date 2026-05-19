from sqlalchemy import (
    BigInteger,
    Boolean,
    Column,
    ForeignKey,
    Index,
    Integer,
    SmallInteger,
    String,
    Text,
    TIMESTAMP,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import DeclarativeBase, relationship


class Base(DeclarativeBase):
    pass


class AdhocReports(Base):
    __tablename__ = "adhoc_reports"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    query = Column(Text, nullable=True)
    short_title = Column(String(64), nullable=True)
    header_text = Column(Text, nullable=True)
    footer_text = Column(Text, nullable=True)
    filename = Column(String(64), nullable=True)
    enabled = Column(Integer, nullable=False, default=0)


class FondFamilies(Base):
    __tablename__ = "fond_families"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    code = Column(String(64), nullable=True)
    name = Column(String(64), nullable=True)
    header_text = Column(Text, nullable=True)
    enabled = Column(SmallInteger, nullable=False, default=1)


class Fonds(Base):
    __tablename__ = "fonds"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    code = Column(String(64), unique=True, nullable=True)
    full_name = Column(String(128), nullable=True)
    header_text = Column(Text, nullable=True)
    image_filename = Column(String(128), nullable=True)
    volume_count = Column(Integer, nullable=True)
    enabled = Column(Boolean, nullable=False, default=True)

    manuscripts = relationship("Manuscripts", back_populates="fond", foreign_keys="Manuscripts.fond_code")


class LinkedSources(Base):
    __tablename__ = "linked_sources"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    raw_shelfmark = Column(String(32), nullable=True)
    shelfmark = Column(String(32), nullable=True)
    url = Column(String(256), nullable=True)
    link_name = Column(String(32), nullable=True)

    __table_args__ = (
        Index("shelfmark_idx", "shelfmark"),
        Index("link_name_idx", "link_name"),
    )


class Manuscripts(Base):
    __tablename__ = "manuscripts"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    shelfmark = Column(String(32), nullable=True)
    author = Column(String(128), nullable=True)
    title = Column(String(256), nullable=True)
    incipit = Column(String(256), nullable=True)
    date = Column(String(32), nullable=True)
    notes = Column(Text, nullable=True)
    high_quality = Column(Integer, nullable=True)
    details_page = Column(Boolean, nullable=True)
    details_count = Column(Integer, nullable=True)
    bibliography_count = Column(Integer, nullable=True)
    thumbnail_url = Column(String(256), nullable=True)
    date_updated = Column(
        TIMESTAMP,
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )
    date_added = Column(TIMESTAMP, nullable=True)
    sort_shelfmark = Column(String(64), nullable=True)
    fond_code = Column(
        String(64),
        ForeignKey("fonds.code", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    ignore = Column(Boolean, nullable=True, default=False)

    fond = relationship("Fonds", back_populates="manuscripts", foreign_keys=[fond_code])

    __table_args__ = (
        UniqueConstraint("shelfmark", "high_quality", name="shelfmark_quality"),
        Index("fond_code_idx", "fond_code"),
    )


class WeeklyNotes(Base):
    __tablename__ = "weekly_notes"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    year = Column(Integer, nullable=True)
    week_number = Column(Integer, nullable=True)
    header_text = Column(Text, nullable=False)
    image_filename = Column(String(128), nullable=True)
    boundry_image_filename = Column(String(128), nullable=True)
    previous_id = Column(
        BigInteger,
        ForeignKey("weekly_notes.id", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    last_updated = Column(TIMESTAMP, nullable=True, server_default=func.now(), onupdate=func.now())
    published = Column(Boolean, nullable=False, default=False)

    previous = relationship("WeeklyNotes", remote_side="WeeklyNotes.id", foreign_keys=[previous_id])

    __table_args__ = (Index("previous_id_idx", "previous_id"),)


class YearlyNotes(Base):
    __tablename__ = "yearly_notes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    year = Column(Integer, nullable=True)
    header_text = Column(Text, nullable=True)
