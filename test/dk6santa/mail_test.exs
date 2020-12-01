defmodule Dk6santa.MailTest do
  use Dk6santa.DataCase

  alias Dk6santa.Mail

  describe "contacts" do
    alias Dk6santa.Mail.Contact

    @valid_attrs %{email: "some email", name: "some name"}
    @invalid_attrs %{email: nil, name: nil}

    def contact_fixture(attrs \\ %{}) do
      {:ok, contact} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Mail.create_contact()

      contact
    end

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      assert Mail.list_contacts() == [contact]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Mail.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      assert {:ok, %Contact{} = contact} = Mail.create_contact(@valid_attrs)
      assert contact.email == "some email"
      assert contact.name == "some name"
      assert contact.uuid |> is_binary()
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mail.create_contact(@invalid_attrs)
    end
  end

  describe "letters" do
    alias Dk6santa.Mail.Letter

    @valid_attrs %{html: "some html", plain: "some plain", subject: "some subject"}
    @invalid_attrs %{html: nil, plain: nil, subject: nil}

    def letter_fixture(attrs \\ %{}) do
      {:ok, letter} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Mail.add_letter()

      letter
    end

    test "list_letters/0 returns all letters" do
      letter = letter_fixture()
      assert Mail.list_letters() == [letter]
    end

    test "get_letter!/1 returns the letter with given id" do
      letter = letter_fixture()
      assert Mail.get_letter!(letter.id) == letter
    end

    test "add_letter/1 with valid data creates a letter" do
      assert {:ok, %Letter{} = letter} = Mail.add_letter(@valid_attrs)
      assert letter.html == "some html"
      assert letter.plain == "some plain"
      assert letter.subject == "some subject"
    end

    test "add_letter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mail.add_letter(@invalid_attrs)
    end
  end
end
