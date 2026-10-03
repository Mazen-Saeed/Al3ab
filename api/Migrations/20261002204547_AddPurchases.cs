using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3b.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddPurchases : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "expected_quantity",
                table: "stock_movements",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "purchase_id",
                table: "stock_movements",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "purchases",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    total = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_by_staff_id = table.Column<Guid>(type: "uuid", nullable: true),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_purchases", x => x.id);
                    table.CheckConstraint("ck_purchases_total", "total >= 0");
                    table.ForeignKey(
                        name: "fk_purchases_staff_staff_id",
                        column: x => x.staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_purchases_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "ix_stock_movements_purchase_id",
                table: "stock_movements",
                column: "purchase_id");

            migrationBuilder.AddCheckConstraint(
                name: "ck_stock_movements_expected",
                table: "stock_movements",
                sql: "expected_quantity IS NULL OR kind = 'Count'");

            migrationBuilder.AddCheckConstraint(
                name: "ck_stock_movements_purchase",
                table: "stock_movements",
                sql: "purchase_id IS NULL OR kind = 'Purchase'");

            migrationBuilder.CreateIndex(
                name: "ix_purchases_staff_id",
                table: "purchases",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_purchases_venue_id_updated_at",
                table: "purchases",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.AddForeignKey(
                name: "fk_stock_movements_purchases_purchase_id",
                table: "stock_movements",
                column: "purchase_id",
                principalTable: "purchases",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_stock_movements_purchases_purchase_id",
                table: "stock_movements");

            migrationBuilder.DropTable(
                name: "purchases");

            migrationBuilder.DropIndex(
                name: "ix_stock_movements_purchase_id",
                table: "stock_movements");

            migrationBuilder.DropCheckConstraint(
                name: "ck_stock_movements_expected",
                table: "stock_movements");

            migrationBuilder.DropCheckConstraint(
                name: "ck_stock_movements_purchase",
                table: "stock_movements");

            migrationBuilder.DropColumn(
                name: "expected_quantity",
                table: "stock_movements");

            migrationBuilder.DropColumn(
                name: "purchase_id",
                table: "stock_movements");
        }
    }
}
