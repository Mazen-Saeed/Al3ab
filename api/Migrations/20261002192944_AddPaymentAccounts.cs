using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3b.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddPaymentAccounts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "instapay_handle",
                table: "venues",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "instapay_link",
                table: "venues",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "instapay_phone",
                table: "venues",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "wallet_link",
                table: "venues",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "wallet_phone",
                table: "venues",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "instapay_handle",
                table: "venues");

            migrationBuilder.DropColumn(
                name: "instapay_link",
                table: "venues");

            migrationBuilder.DropColumn(
                name: "instapay_phone",
                table: "venues");

            migrationBuilder.DropColumn(
                name: "wallet_link",
                table: "venues");

            migrationBuilder.DropColumn(
                name: "wallet_phone",
                table: "venues");
        }
    }
}
