using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class BillConfiguration : IEntityTypeConfiguration<Bill>
{
    public void Configure(EntityTypeBuilder<Bill> builder)
    {
        // A session is paid by one bill (a quick sale has no session, so null is allowed many times).
        builder.HasIndex(b => b.SessionId).IsUnique().HasFilter("deleted_at IS NULL");

        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_bills_subtotal", "subtotal >= 0");
            t.HasCheckConstraint("ck_bills_discount", "discount >= 0 AND discount <= subtotal");
            t.HasCheckConstraint("ck_bills_total", "total = subtotal - discount");
        });
    }
}
