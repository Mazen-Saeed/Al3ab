using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3b.Api.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "customers",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false),
                    phone = table.Column<string>(type: "text", nullable: false),
                    password_hash = table.Column<string>(type: "text", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_customers", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "staff",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false),
                    phone = table.Column<string>(type: "text", nullable: false),
                    password_hash = table.Column<string>(type: "text", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_staff", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "unit_types",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_unit_types", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "venues",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false),
                    phone = table.Column<string>(type: "text", nullable: false),
                    address = table.Column<string>(type: "text", nullable: true),
                    latitude = table.Column<decimal>(type: "numeric(9,6)", precision: 9, scale: 6, nullable: true),
                    longitude = table.Column<decimal>(type: "numeric(9,6)", precision: 9, scale: 6, nullable: true),
                    opens_at = table.Column<TimeOnly>(type: "time without time zone", nullable: true),
                    closes_at = table.Column<TimeOnly>(type: "time without time zone", nullable: true),
                    last_synced_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_venues", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "price_categories",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false),
                    single_hourly_price = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    multi_hourly_price = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_price_categories", x => x.id);
                    table.ForeignKey(
                        name: "fk_price_categories_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "products",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false),
                    price = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    stock_quantity = table.Column<int>(type: "integer", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_products", x => x.id);
                    table.ForeignKey(
                        name: "fk_products_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "rooms",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_rooms", x => x.id);
                    table.ForeignKey(
                        name: "fk_rooms_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "shifts",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    opened_by_staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    opened_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    opening_cash = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    closed_by_staff_id = table.Column<Guid>(type: "uuid", nullable: true),
                    closed_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    expected_cash = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: true),
                    counted_cash = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: true),
                    note = table.Column<string>(type: "text", nullable: true),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_shifts", x => x.id);
                    table.ForeignKey(
                        name: "fk_shifts_staff_closed_by_staff_id",
                        column: x => x.closed_by_staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_shifts_staff_opened_by_staff_id",
                        column: x => x.opened_by_staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_shifts_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "staff_venues",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    role = table.Column<string>(type: "text", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_staff_venues", x => x.id);
                    table.ForeignKey(
                        name: "fk_staff_venues_staff_staff_id",
                        column: x => x.staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_staff_venues_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "walk_in_customers",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: true),
                    phone = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_walk_in_customers", x => x.id);
                    table.ForeignKey(
                        name: "fk_walk_in_customers_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "units",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    room_id = table.Column<Guid>(type: "uuid", nullable: false),
                    unit_type_id = table.Column<Guid>(type: "uuid", nullable: false),
                    price_category_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false),
                    status = table.Column<string>(type: "text", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_units", x => x.id);
                    table.ForeignKey(
                        name: "fk_units_price_categories_price_category_id",
                        column: x => x.price_category_id,
                        principalTable: "price_categories",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_units_rooms_room_id",
                        column: x => x.room_id,
                        principalTable: "rooms",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_units_unit_types_unit_type_id",
                        column: x => x.unit_type_id,
                        principalTable: "unit_types",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_units_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "cash_movements",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    shift_id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    type = table.Column<string>(type: "text", nullable: false),
                    amount = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    note = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cash_movements", x => x.id);
                    table.ForeignKey(
                        name: "fk_cash_movements_shifts_shift_id",
                        column: x => x.shift_id,
                        principalTable: "shifts",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_cash_movements_staff_staff_id",
                        column: x => x.staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_cash_movements_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reservations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    customer_id = table.Column<Guid>(type: "uuid", nullable: true),
                    walk_in_customer_id = table.Column<Guid>(type: "uuid", nullable: true),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: true),
                    status = table.Column<string>(type: "text", nullable: false),
                    confirmation_code = table.Column<string>(type: "text", nullable: true),
                    starts_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ends_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_reservations", x => x.id);
                    table.ForeignKey(
                        name: "fk_reservations_customers_customer_id",
                        column: x => x.customer_id,
                        principalTable: "customers",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_reservations_staff_staff_id",
                        column: x => x.staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_reservations_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_reservations_walk_in_customers_walk_in_customer_id",
                        column: x => x.walk_in_customer_id,
                        principalTable: "walk_in_customers",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reservations_units",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    reservation_id = table.Column<Guid>(type: "uuid", nullable: false),
                    unit_id = table.Column<Guid>(type: "uuid", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_reservations_units", x => x.id);
                    table.ForeignKey(
                        name: "fk_reservations_units_reservations_reservation_id",
                        column: x => x.reservation_id,
                        principalTable: "reservations",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_reservations_units_units_unit_id",
                        column: x => x.unit_id,
                        principalTable: "units",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "sessions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    reservation_id = table.Column<Guid>(type: "uuid", nullable: true),
                    customer_id = table.Column<Guid>(type: "uuid", nullable: true),
                    walk_in_customer_id = table.Column<Guid>(type: "uuid", nullable: true),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    status = table.Column<string>(type: "text", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_sessions", x => x.id);
                    table.ForeignKey(
                        name: "fk_sessions_customers_customer_id",
                        column: x => x.customer_id,
                        principalTable: "customers",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_sessions_reservations_reservation_id",
                        column: x => x.reservation_id,
                        principalTable: "reservations",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_sessions_staff_staff_id",
                        column: x => x.staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_sessions_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_sessions_walk_in_customers_walk_in_customer_id",
                        column: x => x.walk_in_customer_id,
                        principalTable: "walk_in_customers",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "bills",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    session_id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    shift_id = table.Column<Guid>(type: "uuid", nullable: false),
                    subtotal = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    discount = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    total = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    discount_note = table.Column<string>(type: "text", nullable: true),
                    payment_method = table.Column<string>(type: "text", nullable: false),
                    paid_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_bills", x => x.id);
                    table.ForeignKey(
                        name: "fk_bills_sessions_session_id",
                        column: x => x.session_id,
                        principalTable: "sessions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_bills_shifts_shift_id",
                        column: x => x.shift_id,
                        principalTable: "shifts",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_bills_staff_staff_id",
                        column: x => x.staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_bills_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "sessions_products",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    session_id = table.Column<Guid>(type: "uuid", nullable: false),
                    product_id = table.Column<Guid>(type: "uuid", nullable: false),
                    quantity = table.Column<int>(type: "integer", nullable: false),
                    unit_price = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    ordered_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_sessions_products", x => x.id);
                    table.ForeignKey(
                        name: "fk_sessions_products_products_product_id",
                        column: x => x.product_id,
                        principalTable: "products",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_sessions_products_sessions_session_id",
                        column: x => x.session_id,
                        principalTable: "sessions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "sessions_units",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    session_id = table.Column<Guid>(type: "uuid", nullable: false),
                    unit_id = table.Column<Guid>(type: "uuid", nullable: false),
                    started_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ended_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    mode = table.Column<string>(type: "text", nullable: false),
                    hourly_price = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_sessions_units", x => x.id);
                    table.ForeignKey(
                        name: "fk_sessions_units_sessions_session_id",
                        column: x => x.session_id,
                        principalTable: "sessions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_sessions_units_units_unit_id",
                        column: x => x.unit_id,
                        principalTable: "units",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "ix_bills_session_id",
                table: "bills",
                column: "session_id");

            migrationBuilder.CreateIndex(
                name: "ix_bills_shift_id",
                table: "bills",
                column: "shift_id");

            migrationBuilder.CreateIndex(
                name: "ix_bills_staff_id",
                table: "bills",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_bills_venue_id",
                table: "bills",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_cash_movements_shift_id",
                table: "cash_movements",
                column: "shift_id");

            migrationBuilder.CreateIndex(
                name: "ix_cash_movements_staff_id",
                table: "cash_movements",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_cash_movements_venue_id",
                table: "cash_movements",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_customers_phone",
                table: "customers",
                column: "phone",
                unique: true,
                filter: "deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_price_categories_venue_id",
                table: "price_categories",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_products_venue_id",
                table: "products",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_reservations_customer_id",
                table: "reservations",
                column: "customer_id");

            migrationBuilder.CreateIndex(
                name: "ix_reservations_staff_id",
                table: "reservations",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_reservations_venue_id",
                table: "reservations",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_reservations_walk_in_customer_id",
                table: "reservations",
                column: "walk_in_customer_id");

            migrationBuilder.CreateIndex(
                name: "ix_reservations_units_reservation_id",
                table: "reservations_units",
                column: "reservation_id");

            migrationBuilder.CreateIndex(
                name: "ix_reservations_units_unit_id",
                table: "reservations_units",
                column: "unit_id");

            migrationBuilder.CreateIndex(
                name: "ix_rooms_venue_id",
                table: "rooms",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_customer_id",
                table: "sessions",
                column: "customer_id");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_reservation_id",
                table: "sessions",
                column: "reservation_id",
                unique: true,
                filter: "deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_staff_id",
                table: "sessions",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_venue_id",
                table: "sessions",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_walk_in_customer_id",
                table: "sessions",
                column: "walk_in_customer_id");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_products_product_id",
                table: "sessions_products",
                column: "product_id");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_products_session_id",
                table: "sessions_products",
                column: "session_id");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_units_session_id",
                table: "sessions_units",
                column: "session_id");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_units_unit_id",
                table: "sessions_units",
                column: "unit_id");

            migrationBuilder.CreateIndex(
                name: "ix_shifts_closed_by_staff_id",
                table: "shifts",
                column: "closed_by_staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_shifts_opened_by_staff_id",
                table: "shifts",
                column: "opened_by_staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_shifts_venue_id",
                table: "shifts",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_staff_phone",
                table: "staff",
                column: "phone",
                unique: true,
                filter: "deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_staff_venues_staff_id_venue_id",
                table: "staff_venues",
                columns: new[] { "staff_id", "venue_id" },
                unique: true,
                filter: "deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_staff_venues_venue_id",
                table: "staff_venues",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_units_price_category_id",
                table: "units",
                column: "price_category_id");

            migrationBuilder.CreateIndex(
                name: "ix_units_room_id",
                table: "units",
                column: "room_id");

            migrationBuilder.CreateIndex(
                name: "ix_units_unit_type_id",
                table: "units",
                column: "unit_type_id");

            migrationBuilder.CreateIndex(
                name: "ix_units_venue_id",
                table: "units",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_walk_in_customers_venue_id",
                table: "walk_in_customers",
                column: "venue_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "bills");

            migrationBuilder.DropTable(
                name: "cash_movements");

            migrationBuilder.DropTable(
                name: "reservations_units");

            migrationBuilder.DropTable(
                name: "sessions_products");

            migrationBuilder.DropTable(
                name: "sessions_units");

            migrationBuilder.DropTable(
                name: "staff_venues");

            migrationBuilder.DropTable(
                name: "shifts");

            migrationBuilder.DropTable(
                name: "products");

            migrationBuilder.DropTable(
                name: "sessions");

            migrationBuilder.DropTable(
                name: "units");

            migrationBuilder.DropTable(
                name: "reservations");

            migrationBuilder.DropTable(
                name: "price_categories");

            migrationBuilder.DropTable(
                name: "rooms");

            migrationBuilder.DropTable(
                name: "unit_types");

            migrationBuilder.DropTable(
                name: "customers");

            migrationBuilder.DropTable(
                name: "staff");

            migrationBuilder.DropTable(
                name: "walk_in_customers");

            migrationBuilder.DropTable(
                name: "venues");
        }
    }
}
